const { contextBridge, ipcRenderer } = require('electron');

// Exponer una API mínima si es necesario en el futuro
contextBridge.exposeInMainWorld('electronAPI', {
  // Placeholder: add methods to communicate with main if desired
});
