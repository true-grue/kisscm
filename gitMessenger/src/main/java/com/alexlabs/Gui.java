package com.alexlabs;

import java.awt.*;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.List;

public class Gui {

    private final TrayIcon trayIcon;

    public Gui() {
        try {
            SystemTray systemTray = SystemTray.getSystemTray(); // Отображение меню
            Image image = Toolkit.getDefaultToolkit() // Загрузка картинки
                    .createImage(getClass().getResource("/logoH3.png"));

            // Идентификация при наведении мыши на иконку
            trayIcon = new TrayIcon(image, "GitHub Messenger");
            trayIcon.setImageAutoSize(true); // Автоматическая установка размера
            trayIcon.setToolTip("GitHub Messenger"); // Подсказка


            systemTray.add(trayIcon); // Добавление иконки
        } catch (AWTException e) {
            throw new RuntimeException(e);
        }
    }

    public void setMenu(String login, List<RepositoryDescription> repos) { // Меню
        PopupMenu popup = new PopupMenu();

        MenuItem accountMenuItem = new MenuItem(login);
        accountMenuItem.addActionListener(e -> openInBrowser("https://github.com/" + login));

        MenuItem notificationMenuItem = new MenuItem("notifications");
        notificationMenuItem.addActionListener(e -> openInBrowser("https://github.com/notifications"));

        Menu repositoriesMenuItem = new Menu("repositories");
        repos
                .forEach(repo -> {
                    String name = repo.getPullRequests().size() > 0
                            ? String.format("(%d) %s", repo.getPullRequests().size(), repo.getName())
                            : repo.getName();
                    Menu repoSubMenu = new Menu(name);

                    MenuItem openInBrowser = new MenuItem("Open in browser");
                    openInBrowser.addActionListener(e -> openInBrowser(
                            repo
                            .getRepository()
                            .getHtmlUrl()
                            .toString())
                    );

                    repoSubMenu.add(openInBrowser);
                    
                    if (repo.getPullRequests().size() > 0) {
                        repoSubMenu.addSeparator();
                    }

                    repo.getPullRequests()
                            .forEach(pr -> {
                                MenuItem prMenuItem = new MenuItem(pr.getTitle());
                                prMenuItem.addActionListener(e ->
                                        openInBrowser(pr.getRepository().getHtmlUrl().toString())
                                );
                                repoSubMenu.add(prMenuItem);
                            });


                    repositoriesMenuItem.add(repoSubMenu);
                });


        popup.add(accountMenuItem);
        popup.addSeparator();
        popup.add(notificationMenuItem);
        popup.add(repositoriesMenuItem);

        trayIcon.setPopupMenu(popup);
    }

    public void openInBrowser(String url) { // Окрытие браузера
        try {
            Desktop.getDesktop().browse(new URL(url).toURI());
        } catch (IOException | URISyntaxException e) {
            throw new RuntimeException(e);
        }
    }

    public void showNotification(String title, String text) { // Отображение уведомлений
        trayIcon.displayMessage(title, text, TrayIcon.MessageType.INFO);
    }
}
