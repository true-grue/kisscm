package com.alexlabs;

import org.kohsuke.github.GHPullRequest;
import org.kohsuke.github.GHRepository;

import java.util.List;

public class RepositoryDescription { // Вся информация о репозитории
    private String name;
    private GHRepository repository;
    private List<GHPullRequest> pullRequests;

    public RepositoryDescription(String name, GHRepository repository, List<GHPullRequest> pullRequests) {
        this.name = name;
        this.repository = repository;
        this.pullRequests = pullRequests;
    }

    public String getName() {
        return name;
    }

    public GHRepository getRepository() {
        return repository;
    }

    public List<GHPullRequest> getPullRequests() {
        return pullRequests;
    }
}
