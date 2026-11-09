# HotCut CNC — Descargas

Repositorio oficial de descargas de **HotCut CNC**, software de corte por hilo
caliente para máquinas CNC.

Versión actual: **1.0** · Linux (x86_64) y Windows 10/11 (64 bits).

| Edición | Carpeta | Código | Para |
|---|---|---|---|
| **HotCut_PRO** | [`pro/`](pro) | `HCPR` | Todas las funciones (2/3/4 ejes, dual, STL 3D, anidado…) |
| **HotCut 4 Ejes** | [`4axis/`](4axis) | `HC4A` | Máquinas de 4 ejes |
| **HotCut 3 Ejes** | [`3axis/`](3axis) | `HC3A` | Máquinas de 3 ejes |
| **HotCut 2 Ejes** | [`2axis/`](2axis) | `HC2A` | Máquinas de 2 ejes (X/Y) |

> La aplicación necesita **activar una licencia** (incluye prueba de 7 días).
> Se activa en *Herramientas → Gestionar Licencia*. Cada edición tiene su
> propio tipo de licencia: un token de 2 ejes no vale para PRO.

---

## Instalación en Linux (recomendada)

Cada edición trae su propio instalador. Abre una terminal, copia las dos
líneas de tu edición y listo:

### HotCut_PRO

```bash
curl -fsSLO https://raw.githubusercontent.com/hotcut-cnc/apps/main/pro/install.sh
sudo bash install.sh
```

### HotCut 4 Ejes

```bash
curl -fsSLO https://raw.githubusercontent.com/hotcut-cnc/apps/main/4axis/install.sh
sudo bash install.sh
```

### HotCut 3 Ejes

```bash
curl -fsSLO https://raw.githubusercontent.com/hotcut-cnc/apps/main/3axis/install.sh
sudo bash install.sh
```

### HotCut 2 Ejes

```bash
curl -fsSLO https://raw.githubusercontent.com/hotcut-cnc/apps/main/2axis/install.sh
sudo bash install.sh
```

El instalador:

1. detecta si tu sistema usa `.rpm` (Fedora/RHEL) o `.deb` (Ubuntu/Debian) y
   elige el paquete correcto;
2. descarga el artefacto y comprueba su **SHA256**;
3. verifica la **firma OpenPGP** del fichero de sumas con la clave de HotCut
   (huella `B4B0B9C5920C12F239F6DEB6F2F90F2AD6B7E2E2`);
4. en Fedora importa la clave pública e instala con `dnf` (Fedora 45 o
   posterior exige paquetes firmados; no hace falta `--nogpgcheck`);
5. en Ubuntu/Debian instala con `apt`.

> Si quieres revisar el script antes de ejecutarlo:
> `less install.sh` (o ábrelo en GitHub antes de descargarlo).

### Opciones útiles

```bash
sudo bash install.sh --dry-run      # muestra los comandos sin instalar nada
bash install.sh --portable          # sin root: instala en ~/.local/bin
sudo bash install.sh --uninstall    # desinstalar
```

### Instalador genérico (una sola descarga)

Si prefieres un único script para cualquier edición:

```bash
curl -fsSLO https://raw.githubusercontent.com/hotcut-cnc/apps/main/install.sh
sudo bash install.sh --edition pro      # pro | 4axis | 3axis | 2axis
```

---

## Windows

Descarga el instalador de tu edición y ejecútalo:

| Edición | Instalador |
|---|---|
| HotCut_PRO | [HotCut_PRO-setup-1.0.exe](pro/windows/HotCut_PRO-setup-1.0.exe) |
| HotCut 4 Ejes | [HotCut-4-Ejes-setup-1.0.exe](4axis/windows/HotCut-4-Ejes-setup-1.0.exe) |
| HotCut 3 Ejes | [HotCut-3-Ejes-setup-1.0.exe](3axis/windows/HotCut-3-Ejes-setup-1.0.exe) |
| HotCut 2 Ejes | [HotCut-2-Ejes-setup-1.0.exe](2axis/windows/HotCut-2-Ejes-setup-1.0.exe) |

El instalador no está firmado con un certificado de Windows, así que
SmartScreen puede avisar la primera vez: *Más información → Ejecutar de todas
formas*.

---

## Descargas manuales (Linux)

Si prefieres gestionar tú el paquete, estos son los ficheros de cada edición.

### HotCut_PRO

| Formato | Fichero |
|---|---|
| Binario portable | [hotcut-pro-1.0](pro/linux/hotcut-pro-1.0) |
| Ubuntu / Debian | [hotcut-pro_1.0_amd64.deb](pro/linux/hotcut-pro_1.0_amd64.deb) |
| Fedora / RHEL | [hotcut-pro-1.0-1.x86_64.rpm](pro/linux/hotcut-pro-1.0-1.x86_64.rpm) |

### HotCut 4 Ejes

| Formato | Fichero |
|---|---|
| Binario portable | [hotcut-4axis-1.0](4axis/linux/hotcut-4axis-1.0) |
| Ubuntu / Debian | [hotcut-4axis_1.0_amd64.deb](4axis/linux/hotcut-4axis_1.0_amd64.deb) |
| Fedora / RHEL | [hotcut-4axis-1.0-1.x86_64.rpm](4axis/linux/hotcut-4axis-1.0-1.x86_64.rpm) |

### HotCut 3 Ejes

| Formato | Fichero |
|---|---|
| Binario portable | [hotcut-3axis-1.0](3axis/linux/hotcut-3axis-1.0) |
| Ubuntu / Debian | [hotcut-3axis_1.0_amd64.deb](3axis/linux/hotcut-3axis_1.0_amd64.deb) |
| Fedora / RHEL | [hotcut-3axis-1.0-1.x86_64.rpm](3axis/linux/hotcut-3axis-1.0-1.x86_64.rpm) |

### HotCut 2 Ejes

| Formato | Fichero |
|---|---|
| Binario portable | [hotcut-2axis-1.0](2axis/linux/hotcut-2axis-1.0) |
| Ubuntu / Debian | [hotcut-2axis_1.0_amd64.deb](2axis/linux/hotcut-2axis_1.0_amd64.deb) |
| Fedora / RHEL | [hotcut-2axis-1.0-1.x86_64.rpm](2axis/linux/hotcut-2axis-1.0-1.x86_64.rpm) |

### Instalación manual

**Ubuntu / Debian**

```bash
sudo apt install ./hotcut-pro_1.0_amd64.deb     # cambia el nombre por tu edición
```

**Fedora / RHEL** (paquete firmado; importa la clave una sola vez)

```bash
sudo rpm --import RPM-GPG-KEY-hotcut.asc
sudo dnf install ./hotcut-pro-1.0-1.x86_64.rpm
rpm -Kv ./hotcut-pro-1.0-1.x86_64.rpm          # → "firmas ... OK"
```

**Binario portable** (sin instalar, sin root)

```bash
chmod +x hotcut-pro-1.0
./hotcut-pro-1.0
```

---

## Verificar la descarga

Cada carpeta `<edición>/linux/` incluye `SHA256SUMS` y su firma
`SHA256SUMS.asc`. Ejemplo con la edición PRO:

```bash
BASE=https://raw.githubusercontent.com/hotcut-cnc/apps/main/pro/linux
curl -fsSLO "$BASE/SHA256SUMS"
curl -fsSLO "$BASE/SHA256SUMS.asc"
curl -fsSLO "$BASE/RPM-GPG-KEY-hotcut.asc"
curl -fsSLO "$BASE/hotcut-pro-1.0-1.x86_64.rpm"

gpg --import RPM-GPG-KEY-hotcut.asc
gpg --verify SHA256SUMS.asc SHA256SUMS
sha256sum -c --ignore-missing SHA256SUMS
```

Huella de la clave de release:

```
B4B0 B9C5 920C 12F2 39F6  DEB6 F2F9 0F2A D6B7 E2E2
```

El instalador `install.sh` ya hace estas comprobaciones automáticamente.

---

## Requisitos

- **Linux x86_64**: Ubuntu 24.04 o posterior / Debian 13 o posterior (`.deb`),
  o Fedora/RHEL con `dnf` (`.rpm`). El binario portable necesita `glibc` 2.39
  o superior.
- **Windows 10 u 11 de 64 bits**.
- GPU no imprescindible: la vista 3D usa aceleración si está disponible.
- Internet solo para activar o renovar la licencia (la app avisa antes y
  concede varios días de gracia sin conexión).

---

## Desinstalar

```bash
# Linux con paquete
sudo dnf remove hotcut-pro      # Fedora/RHEL  (o hotcut-4axis, -3axis, -2axis)
sudo apt remove hotcut-pro      # Ubuntu/Debian

# Linux portable instalado con install.sh
sudo bash install.sh --uninstall

# Windows
Configuración → Aplicaciones → HotCut … → Desinstalar
```

La configuración y la licencia se guardan en la carpeta del usuario. Para
borrarlas por completo, elimina `~/.hotwireCut` (Linux) o la carpeta
equivalente en `%APPDATA%` (Windows).

---

## Contenido del repositorio

```
.
├── README.md                  # este fichero
├── install.sh                 # instalador genérico (--edition …)
├── pro/                       # HotCut_PRO
│   ├── install.sh             #   instalador con la edición ya fijada
│   ├── linux/                 #   binario, .deb, .rpm, clave y sumas
│   └── windows/               #   instalador .exe
├── 4axis/                     # HotCut 4 Ejes (misma estructura)
├── 3axis/                     # HotCut 3 Ejes
└── 2axis/                     # HotCut 2 Ejes
```

Cada `linux/latest.txt` contiene la versión publicada (la lee `install.sh`, así
las instrucciones de arriba siguen valiendo en versiones futuras).

---

## Soporte

- Web: <https://termocortadoras-cnc.es>
- Correo: <soporte@termocortadoras-cnc.es>

Indica en el mensaje la edición, el sistema operativo y, si es un problema de
instalación, el texto completo que muestra `install.sh`.
