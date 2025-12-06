# Instrucciones para publicar en GitHub Pages

## Requisitos previos
1. **Cuenta GitHub** (gratis) - si no tienes, crea una en https://github.com/signup
2. **Git instalado** en tu PC - descarga desde https://git-scm.com (en Windows, la instalación es estándar)

## Pasos rápidos (5 minutos)

### 1. Crea un repositorio nuevo en GitHub
- Ve a https://github.com/new
- Nombre: `fxracer` (o el que prefieras)
- Selecciona **Public**
- Haz clic en **Create repository**
- GitHub te mostrará la URL: `https://github.com/TU_USUARIO/fxracer.git`
  (copia esta URL, la necesitarás)

### 2. Ejecuta el script de deploy
Abre **PowerShell** en esta carpeta (`c:\Users\user\OneDrive\Desktop\CURSO HTML`) y ejecuta:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
.\deploy-github.ps1
```

El script te pedirá:
- **URL del repositorio**: pega la URL que copiaste en el paso 1
  Ejemplo: `https://github.com/juan123/fxracer.git`

Luego hará automáticamente:
- Inicializa Git
- Añade todos los archivos
- Crea un commit
- Sube todo a GitHub

**Si te pide usuario/contraseña:**
- Opción A: usa tu usuario + contraseña de GitHub
- Opción B (más seguro): genera un Personal Access Token en https://github.com/settings/tokens
  y úsalo como contraseña

### 3. Habilita GitHub Pages
- Ve a tu repositorio: `https://github.com/TU_USUARIO/fxracer`
- Haz clic en **Settings** (engranaje, arriba a la derecha)
- En el menú izquierdo, selecciona **Pages**
- En **Source**, elige **Deploy from a branch** → **main** → **Save**

GitHub te mostrará un mensaje confirmando:
```
Your site is published at https://TU_USUARIO.github.io/fxracer
```

### 4. Accede desde tu móvil
Abre en el navegador del móvil:
```
https://TU_USUARIO.github.io/fxracer
```

(Ejemplo: si tu usuario es "juan123", la URL es `https://juan123.github.io/fxracer`)

## Solución de problemas

### Error: "PowerShell execution policy"
Ejecuta primero:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Luego vuelve a correr el script.

### Error: "Git no está instalado"
Descarga Git desde https://git-scm.com y reinstala (opción estándar).

### Error en "git push" (autenticación)
- Si usas usuario/contraseña: asegúrate de que es correcto
- Si usas token: ve a https://github.com/settings/tokens y genera uno nuevo (permisos: repo)
- En Windows, git puede pedir credenciales en una ventana separada — complétala

### La página no aparece después de Pages habilitado
- GitHub Pages tarda 1-2 minutos en propagar
- Abre https://github.com/TU_USUARIO/fxracer/settings/pages y verifica que esté en verde
- Limpia el cache del navegador (Ctrl+Shift+Del)

## Actualizar el sitio después
Cada vez que cambies archivos y quieras subirlos a GitHub:

```powershell
cd 'C:\Users\user\OneDrive\Desktop\CURSO HTML'
git add .
git commit -m "Actualización: descripción del cambio"
git push
```

El sitio se actualizará automáticamente en unos segundos.
