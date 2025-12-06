# Publicar en GitHub Pages

Este repositorio contiene una página estática (`index.html`) para gestionar puntos de pilotos y constructores.

A continuación tienes instrucciones rápidas para publicar el sitio en GitHub Pages (HTTPS incluido).

## Opciones recomendadas

### Opción 1 — Publicar con GitHub Pages (rápido)
1. Crea un repositorio en GitHub (por ejemplo `fxracer-sumador`).
2. Desde la carpeta del proyecto en tu máquina, inicializa y sube:

```powershell
# desde c:\Users\user\OneDrive\Desktop\CURSO HTML
git init
git add .
git commit -m "Publicar sitio fxracer"
# sustituye la URL por la de tu repo en GitHub
git remote add origin https://github.com/tu-usuario/tu-repo.git
git branch -M main
git push -u origin main
```

3. En GitHub, ve a Settings → Pages y selecciona la rama `main` (o `master`) y la carpeta `/ (root)` como fuente. Guarda.
4. GitHub Pages publicará el sitio en `https://tu-usuario.github.io/tu-repo/` (HTTPS activo por defecto).

> Ventaja: HTTPS automático, fácil de mantener y gratuito.

### Opción 2 — Deploy automático con Netlify (drag & drop)
1. Ve a netlify.com y crea una cuenta gratuita.
2. En el panel, arrastra la carpeta `CURSO HTML` (o el zip) a "Sites" → "New site from folder" (drag & drop).
3. Netlify te dará una URL con HTTPS automáticamente.

### Opción 3 — Compartir localmente por HTTPS (temporal)
Si no quieres subir el repo, puedes exponer tu servidor local con ngrok (genera URL HTTPS pública temporal):

```powershell
# iniciar un servidor simple en la carpeta
python -m http.server 8000
# en otra terminal, si tienes ngrok instalado
ngrok http 8000
# ngrok mostrará una URL https://xxxx.ngrok.io que puedes compartir
```

## Recomendaciones de seguridad
- GitHub Pages y Netlify proporcionan HTTPS automáticamente.
- Asegúrate de que todas las URLs externas en `index.html` usen `https://` para evitar mixed content.
- No almacenes datos sensibles en `localStorage` si el sitio se va a compartir con usuarios.
- Considera añadir una política CSP o cabeceras HTTP si más adelante sirves desde tu propio servidor.

## Siguientes pasos que puedo hacer por ti
- Preparar el repo y empujarlo a GitHub (necesito que me pongas la URL del repo o que me des permisos para operar).  
- Generar un `README.md` (ya creado), o un workflow de GitHub Actions para desplegar automáticamente a `gh-pages`.  
- Crear un `logos/ferrari.png` placeholder si quieres un logo local.
Si quieres, te doy los comandos listos para ejecutar en PowerShell para empujar el repo (modifica la URL remota por la de tu repo).

## Probar la PWA y las actualizaciones (service worker)

1) Servir localmente (localhost acepta instalar PWAs en la mayoría de navegadores):

```powershell
cd "C:\Users\user\OneDrive\Desktop\CURSO HTML"
python -m http.server 8000
# Abrir http://localhost:8000 en tu navegador
```

2) Verificar manifest y service worker:
	- Abre DevTools → Application → Manifest — deberías ver los datos del manifest.
	- En Application → Service Workers deberías ver `sw.js` registrado.

3) Forzar y probar actualización del SW (flujo de actualización):
	- Edita `sw.js` cambiando la constante `CACHE_VERSION` a otro valor (p.ej. 'v3') y guarda.
	- Abre la página y observa en DevTools → Application → Service Workers: el nuevo worker pasará a estado `waiting`.
	- La página mostrará un pequeño toast "Actualización disponible"; pulsa "Recargar" para que la nueva versión se active.
	- Al aceptar, la página recargará controlada por el nuevo service worker.

4) Compartir públicamente (HTTPS necesario para instalación fuera de localhost):
	- Despliega en GitHub Pages o Netlify (ambos ofrecen HTTPS automático). Luego visita la URL HTTPS y el navegador permitirá instalar la PWA.

Si quieres, puedo automatizar el cambio de versión y crear un pequeño script de release para incrementar `CACHE_VERSION` cuando publiques una nueva versión.

## Ejecutar como app de Escritorio con Electron

Si quieres ejecutar la página como una aplicación de escritorio, sigue estos pasos (necesitas Node.js y npm instalados):

1. En PowerShell, instala dependencias:

```powershell
cd "C:\Users\user\OneDrive\Desktop\CURSO HTML"
npm install
```

2. Para ejecutar la app en modo desarrollo:

```powershell
npm start
```

3. Para empaquetar una versión para Windows (usa `electron-packager` incluido en devDependencies):

```powershell
npm run pack
```

Notas:
- Si no tienes `electron-packager` instalado globalmente, el script lo usa desde `devDependencies` tras `npm install`.
- Puedes ajustar `package.json` (campo `scripts.pack`) para cambiar plataforma/arquitectura.
- Si prefieres un instalador (.exe/msi), te recomiendo usar `electron-builder` para crear instaladores multiplataforma.