const { app, BrowserWindow, Menu, session, ipcMain } = require('electron');
const path = require('path');

function createWindow() {
    const win = new BrowserWindow({
        width: 1280,
        height: 900,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            partition: 'persist:fandiSessao', // <<< mantém sessão automática
        }
    });

    // URL única permitida
    const URL_FANDI = "https://app10.fandi.com.br/login";

    win.loadURL(URL_FANDI);

    // Impede navegação para outros domínios
    win.webContents.on('will-navigate', (event, url) => {
        if (!url.startsWith("https://app10.fandi.com.br")) {
            event.preventDefault();
            win.loadURL(URL_FANDI);
        }
    });

    win.webContents.setWindowOpenHandler(({ url }) => {
        // impede abrir novas janelas fora do domínio permitido
        if (!url.startsWith("https://app10.fandi.com.br")) {
            return { action: 'deny' };
        }
        return { action: 'allow' };
    });

    // Menu simplificado com botão limpar sessão
    const menu = Menu.buildFromTemplate([
        {
            label: "Sessão",
            submenu: [
                {
                    label: "Limpar sessão",
                    click: () => {
                        session.fromPartition('persist:fandiSessao')
                            .clearStorageData()
                            .then(() => {
                                win.loadURL(URL_FANDI);
                            });
                    }
                }
            ]
        }
    ]);

    Menu.setApplicationMenu(menu);
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    app.quit();
});
