#!/usr/bin/env bash
# HotCut CNC — instalador para Linux (Fedora/RHEL, Ubuntu/Debian o portable).
#
# Uso recomendado (revisando antes el script):
#   curl -fsSLO https://raw.githubusercontent.com/hotcut-cnc/apps/main/pro/install.sh
#   less install.sh
#   sudo bash install.sh
#
# El instalador genérico (sin edición predefinida) está en la raíz del repo:
#   curl -fsSLO https://raw.githubusercontent.com/hotcut-cnc/apps/main/install.sh
#   sudo bash install.sh --edition pro
#
# Ejemplos:
#   sudo bash install.sh --edition 4axis              # detecta rpm o deb
#   sudo bash install.sh --edition 4axis --method rpm # fuerza paquete rpm
#   bash install.sh --edition pro --portable          # sin root, en ~/.local/bin
#   sudo bash install.sh --edition pro --uninstall
#   bash install.sh --edition pro --dry-run           # solo muestra lo que haría
#
# El artefacto se verifica con SHA256SUMS-<edición> y la firma OpenPGP de ese
# fichero (misma clave con la que se firman los .rpm). Si no hay gpg, en la
# ruta rpm la integridad la garantiza la firma del propio paquete.
set -euo pipefail

APP="HotCut CNC"
DEFAULT_BASE_URL="https://raw.githubusercontent.com/hotcut-cnc/apps/main"
DEFAULT_VERSION="1.0"
# Edición por defecto. Las copias dentro de cada carpeta (pro/install.sh,
# 4axis/install.sh, …) la cambian para que `sudo bash install.sh` baste.
DEFAULT_EDITION="2axis"
# Huella de la clave de release de HotCut (Termocortadoras CNC).
KEY_FPR="B4B0B9C5920C12F239F6DEB6F2F90F2AD6B7E2E2"
KEY_FILE="RPM-GPG-KEY-hotcut.asc"

EDITION="$DEFAULT_EDITION"
VERSION=""
BASE_URL="$DEFAULT_BASE_URL"
METHOD="auto"          # auto | rpm | deb | portable
PREFIX=""
UNINSTALL=0
DRY_RUN=0
ASSUME_YES=0

die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }
run()  { if [ "$DRY_RUN" = "1" ]; then echo "    [dry-run] $*"; else "$@"; fi; }

usage() { awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print; next} NR>1 {exit}' "$0"; exit 0; }

while [ $# -gt 0 ]; do
    case "$1" in
        --edition|-e)   EDITION="${2:-}"; shift 2 ;;
        --version|-V)   VERSION="${2:-}"; shift 2 ;;
        --base-url)     BASE_URL="${2:-}"; shift 2 ;;
        --method)       METHOD="${2:-}"; shift 2 ;;
        --portable)     METHOD="portable"; shift ;;
        --prefix)       PREFIX="${2:-}"; shift 2 ;;
        --uninstall)    UNINSTALL=1; shift ;;
        --dry-run)      DRY_RUN=1; shift ;;
        --yes|-y)       ASSUME_YES=1; shift ;;
        --help|-h)      usage ;;
        *) die "opción desconocida: $1 (usa --help)" ;;
    esac
done

# ── Edición → nombre de paquete/fichero ────────────────────────────────────
case "$EDITION" in
    pro|PRO|"")           EDITION="pro";  SLUG="pro" ;;
    4|4axis|4-axis|4ejes) EDITION="4axis"; SLUG="4axis" ;;
    3|3axis|3-axis|3ejes) EDITION="3axis"; SLUG="3axis" ;;
    2|2axis|2-axis|2ejes) EDITION="2axis"; SLUG="2axis" ;;
    *) die "edición desconocida '$EDITION' (pro | 4axis | 3axis | 2axis)" ;;
esac
PKG="hotcut-$SLUG"

command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 \
    || die "hace falta curl o wget"

# ── Detección de familia de distro ─────────────────────────────────────────
detect_family() {
    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case " ${ID:-} ${ID_LIKE:-} " in
            *debian*|*ubuntu*) echo deb; return ;;
            *fedora*|*rhel*|*centos*|*rocky*|*almalinux*|*oracle*) echo rpm; return ;;
        esac
    fi
    command -v dnf >/dev/null 2>&1 && { echo rpm; return; }
    command -v apt-get >/dev/null 2>&1 && { echo deb; return; }
    echo portable
}

[ "$(uname -m)" = "x86_64" ] || die "solo hay binarios x86_64 (detectado: $(uname -m))"

if [ "$METHOD" = "auto" ]; then
    METHOD="$(detect_family)"
    [ "$METHOD" = "rpm" ] && ! command -v dnf >/dev/null 2>&1 && command -v yum >/dev/null 2>&1 && METHOD="rpm"
    [ "$METHOD" = "deb" ] && ! command -v apt-get >/dev/null 2>&1 && METHOD="portable"
fi
case "$METHOD" in
    rpm|deb|portable) ;;
    *) die "--method debe ser auto|rpm|deb|portable" ;;
esac

# ── ¿root? ─────────────────────────────────────────────────────────────────
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        [ "$METHOD" = "portable" ] || [ "$DRY_RUN" = "1" ] || [ "$UNINSTALL" = "1" ] \
            || die "hace falta root/sudo (o usa --portable)"
    fi
fi

# ── Desinstalación ─────────────────────────────────────────────────────────
if [ "$UNINSTALL" = "1" ]; then
    case "$METHOD" in
        rpm) info "desinstalando $PKG (dnf)" ;;
        deb) info "desinstalando $PKG (apt)" ;;
        *)   info "desinstalando portable" ;;
    esac
    case "$METHOD" in
        rpm) run $SUDO dnf remove -y "$PKG" ;;
        deb) run $SUDO apt-get remove -y "$PKG" ;;
        portable)
            P="${PREFIX:-$HOME/.local}"
            if [ -f "$P/bin/hotcut-$SLUG" ]; then
                run rm -f "$P/bin/hotcut-$SLUG"
            else
                info "no hay binario portable en $P/bin/hotcut-$SLUG"
            fi
            ;;
    esac
    info "hecho"
    exit 0
fi

# ── Descarga ───────────────────────────────────────────────────────────────
TMP="$(mktemp -d "${TMPDIR:-/tmp}/hotcut-install.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT INT TERM

fetch() { # fetch <nombre-remoto> <destino>
    local name="$1" dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --retry 2 --connect-timeout 15 "$name" -o "$dest"
    else
        wget -q -O "$dest" "$name"
    fi
}

# Intenta <base>/<edicion>/<f> y, si falla, <base>/<f> (GitHub Releases = plano).
fetch_asset() { # fetch_asset <fichero> [opcional]
    local f="$1" optional="${2:-0}" ok=0
    for url in "$BASE_URL/$EDITION/linux/$f" "$BASE_URL/$EDITION/$f" "$BASE_URL/$f"; do
        if fetch "$url" "$TMP/$f" 2>/dev/null; then ok=1; break; fi
    done
    if [ "$ok" != "1" ]; then
        [ "$optional" = "1" ] && return 0
        die "no se pudo descargar '$f' (probado $BASE_URL/$EDITION/linux/, $BASE_URL/$EDITION/ y $BASE_URL/)"
    fi
}

# Versión: --version, o latest.txt del servidor, o la del script.
if [ -z "$VERSION" ]; then
    fetch_asset "latest.txt" 1 || true
    if [ -s "$TMP/latest.txt" ]; then
        VERSION="$(tr -d '[:space:]' < "$TMP/latest.txt")"
    fi
    [ -n "$VERSION" ] || VERSION="$DEFAULT_VERSION"
fi

case "$METHOD" in
    rpm)      ARTIFACT="$PKG-$VERSION-1.x86_64.rpm" ;;
    deb)      ARTIFACT="${PKG}_${VERSION}_amd64.deb" ;;
    portable) ARTIFACT="$PKG-$VERSION" ;;
esac

info "$APP $VERSION · edición $EDITION · método $METHOD"
info "descargando $ARTIFACT"
fetch_asset "$ARTIFACT"
# SHA256SUMS por edición (para hosting plano tipo GitHub Releases) o genérico.
SUMS="SHA256SUMS-$SLUG"
SUMS_ASC="SHA256SUMS-$SLUG.asc"
fetch_asset "$SUMS" 1
if [ ! -s "$TMP/$SUMS" ]; then
    SUMS="SHA256SUMS"
    SUMS_ASC="SHA256SUMS.asc"
    fetch_asset "$SUMS"
fi
fetch_asset "$KEY_FILE" 1 || true

# ── Verificación ───────────────────────────────────────────────────────────
( cd "$TMP" && sha256sum -c --ignore-missing "$SUMS" >/dev/null 2>&1 ) \
    || die "el SHA256 de $ARTIFACT no coincide con $SUMS"
info "hash SHA256 correcto"

if command -v gpg >/dev/null 2>&1 && [ -s "$TMP/$KEY_FILE" ] && fetch_asset "$SUMS_ASC" 1; then
    if [ -s "$TMP/$SUMS_ASC" ]; then
        mkdir -p "$TMP/gnupg" && chmod 700 "$TMP/gnupg"
        gpg --homedir "$TMP/gnupg" --batch --quiet --import "$TMP/$KEY_FILE" 2>/dev/null || true
        FPR=$(gpg --homedir "$TMP/gnupg" --batch --with-colons --fingerprint 2>/dev/null \
              | awk -F: '/^fpr:/{print $10; exit}')
        [ "$FPR" = "$KEY_FPR" ] \
            || die "la clave pública descargada no es la de HotCut (huella $FPR)"
        gpg --homedir "$TMP/gnupg" --batch --quiet --verify \
            "$TMP/$SUMS_ASC" "$TMP/$SUMS" 2>/dev/null \
            || die "la firma de $SUMS no es válida"
        info "firma GPG de $SUMS correcta ($KEY_FPR)"
    fi
else
    info "aviso: gpg no disponible; no se comprueba la firma de $SUMS"
    if [ "$METHOD" = "rpm" ]; then
        info "        (la firma del .rpm se comprueba igualmente con rpm)"
    fi
fi

# ── Instalación ────────────────────────────────────────────────────────────
case "$METHOD" in
    rpm)
        # La clave debe estar en el keyring de rpm (Fedora 45 exige firma).
        if ! command -v rpm >/dev/null 2>&1 \
           || ! rpm -qa 'gpg-pubkey*' 2>/dev/null | grep -qiF "${KEY_FPR: -16}"; then
            [ -s "$TMP/$KEY_FILE" ] || die "falta $KEY_FILE para importar la clave"
            info "importando clave pública en rpm"
            run $SUDO rpm --import "$TMP/$KEY_FILE"
        fi
        info "instalando $ARTIFACT"
        if command -v dnf >/dev/null 2>&1 || [ "$DRY_RUN" = "1" ]; then
            run $SUDO dnf install -y "$TMP/$ARTIFACT"
        elif command -v yum >/dev/null 2>&1; then
            run $SUDO yum install -y "$TMP/$ARTIFACT"
        else
            run $SUDO rpm -Uvh "$TMP/$ARTIFACT"
        fi
        BIN="/usr/bin/$PKG"
        ;;
    deb)
        info "instalando $ARTIFACT"
        run $SUDO apt-get install -y "$TMP/$ARTIFACT"
        BIN="/usr/bin/$PKG"
        ;;
    portable)
        if [ -z "$PREFIX" ]; then
            if [ "$(id -u)" -eq 0 ]; then PREFIX="/usr/local"; else PREFIX="$HOME/.local"; fi
        fi
        run mkdir -p "$PREFIX/bin"
        run install -m 0755 "$TMP/$ARTIFACT" "$PREFIX/bin/hotcut-$SLUG"
        BIN="$PREFIX/bin/hotcut-$SLUG"
        case ":$PATH:" in
            *":$PREFIX/bin:"*) ;;
            *) info "añade a tu PATH: export PATH=\"$PREFIX/bin:\$PATH\"" ;;
        esac
        ;;
esac

if [ "$DRY_RUN" = "1" ]; then
    info "dry-run terminado; no se ha instalado nada"
    exit 0
fi

info "instalado: $BIN"
info "abre 'HotCut CNC' desde el menú o ejecuta: $BIN"
info "la app pedirá activar la licencia (Herramientas → Gestionar Licencia)"
info "manual: docs/Manual_Usuario_HotCut_CNC.md"
