# Use Case

- One simple nodejs project with a `Dockerfile`.
- One local NPM dependency used by the above project (copied to container via Dockerfile). The project refers to the dependency via a [local path](https://docs.npmjs.com/files/package.json#local-paths).
- The nodejs project has one web route (`/`) that prints the version of the local npm dependency from its `package.json`.  This is used to verify the results of the test case procedure.
- [The docker-compose.yml file](https://github.com/twelve17/dc-test/blob/master/docker-compose.yml#L23) uses [this volume technique](http://jdlm.info/articles/2016/03/06/lessons-building-node-app-docker.html) to overlay the host machine's source tree
  on top of the container's source tree and then overlaying the `node_modules` from the container on top of the first volume.


## Steps to Reproduce

1. Clone [this repo](https://github.com/twelve17/dc-test).
2. Clean up any previous containers and images related to this repo's project via `docker rm` and `docker rmi`.
3. Check out the `test2_run1` tag. This state represents the project using version 1.0.0 of the local NPM dependency.
4. Do a `docker-compose build`.  All steps should run without any cache usage if step 2 was followed correctly.
Note the version of the local NPM dependency during the `npm install` command, e.g. `+-- my-npm@1.0.0`.
5. Do a `docker-compose up`.  Browse to `http://localhost:8000`.  The page should report version `1.0.0`.
6. Stop the running containers. (Ctrl-C on the terminal from which the `up` command was issued.)
7. Check out the `test2_run2` tag. This introduces [a small change](https://github.com/twelve17/dc-test/compare/test2_run1...test2_run2) to the NPM's `index.js` file, and a version
   bump in its `package.json` to `1.0.1`.
8. Do a `docker-compose build`.  **Only the instructions up to `COPY ./my-npm ...` should use a cache.** (E.g., the docker output prints `---> Using cache` for that instruction.)  All subsequent steps should be run by docker.  This is because the changes introduced in step 7 to the NPM package should have invalidated the cache for the `COPY ./my-npm ...` command, and, as a result, subsequent steps too.  Confirm that during the `npm install` command, the new version of the NPM is printed in the summary tree output, e.g. `+-- my-npm@1.0.1`.
9. Do a `docker-compose up`.  Browse to `http://localhost:8000`.  The page should report version `1.0.1`.

Expected behavior: Page in step 9 should report `1.0.1`.  That is, a change in the local npm should be reflected in the container via `docker-compose up`.

Actual behavior: Page in step 9 reports `1.0.0`.

**Note that docker itself is re-building images as expected.**  The observed issue is not that docker is re-using a cached image, as the output
shows it re-running NPM install and showing the new version of the local NPM dependency.  The issue is that `docker-compose` is not seeing
that the underlying images that comprise the `dctest_service1` container have been updated.

In fact, running bash in the container allows us to see that the container has the updated `my-npm` module files, but the `node_modules`
version is stale:

```
  # docker exec -it dctest_service1_1 bash
  app@6bf2671b75c6:~/service1$ grep version  my-npm/package.json  node_modules/my-npm/package.json
  my-npm/package.json:  "version": "1.0.1",
  node_modules/my-npm/package.json:  "version": "1.0.0"
  app@6bf2671b75c6:~/service1$
```

Workaround: Use `docker rm` to remove the `dctest_service1` container.  Then re-run `docker-compose up`, which will re-create the container using the existing images.  Notable in this step is that no underlying images are re-built.  In re-creating the container, `docker-compose` seems to figure out to use the newer volume that has the updated `node_modules`.

See the [`output`](https://github.com/twelve17/dc-test/tree/master/output) directory for the output printed during the first run (steps 4 and 5) and the second run (steps 8 and 9).
