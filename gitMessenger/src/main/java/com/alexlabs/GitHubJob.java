package com.alexlabs;

import org.kohsuke.github.*;

import java.io.IOException;
import java.sql.Time;
import java.util.*;
import java.util.stream.Collectors;

public class GitHubJob {

    private final GitHub github_token;
    private final Gui gui = new Gui();
    private final Set<Long> allPullRequestsIds = new HashSet<>(); // Хранилище всех pull request-ов

    public GitHubJob() {
        try {
            github_token = new GitHubBuilder()
                    .withAppInstallationToken(System.getenv("GITHUB_TOKEN")) // Аутентификация в приложении
                    .build();
            init();
        } catch (IOException e) {
            throw new RuntimeException(e); // Исключение, если не проинециализировался gitHub
        }
    }

    private void init() throws IOException {
        final GHMyself myself = github_token.getMyself();
        String login = myself.getLogin();

        new Timer().schedule(new TimerTask() {
            @Override
            public void run() {
                try {
                    boolean notifyForNewPullRequests = !allPullRequestsIds.isEmpty(); // Если ничего нет, то уведомление не нужно

                    HashSet<GHPullRequest> newPullRequests = new HashSet<>();

                    List<RepositoryDescription> repos = myself.getAllRepositories()
                            .values()
                            .stream()
                            .map(repository -> {
                                try {
                                    List<GHPullRequest> pullRequests = repository.queryPullRequests() // Запрос pull request репозитория и вывод его в список
                                            .list()
                                            .toList();

                                    Set<Long> pullRequestsIds = pullRequests.stream() // Формирование списка ID pull request-ов
                                            .map(GHPullRequest::getId)
                                            .collect(Collectors.toSet());
                                    pullRequestsIds.removeAll(allPullRequestsIds); // Удаление всех сохраненных pull request-ов, остались только новые ID
                                    allPullRequestsIds.addAll(pullRequestsIds);
                                    pullRequests.forEach(pullRequest -> {
                                        if (pullRequestsIds.contains(pullRequest.getId())) { // Если содержит pull request, рассматриваемый в цикле
                                            newPullRequests.add(pullRequest);
                                        }
                                    });

                                    return new RepositoryDescription(
                                            repository.getFullName(),
                                            repository,
                                            pullRequests
                                    );
                                } catch (IOException e) {
                                    throw new RuntimeException(e);
                                }
                            }) // Получение всех репозиториев
                            .collect(Collectors.toList());

                    gui.setMenu(login, repos);

                    if (notifyForNewPullRequests) {
                        newPullRequests.forEach(pullRequest -> {
                            gui.showNotification(
                                    "New Pull Request in" + pullRequest.getRepository().getFullName(),
                                    pullRequest.getTitle())
                            ;
                        });
                    }
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
        }, 1000, 1000);
    }
}
