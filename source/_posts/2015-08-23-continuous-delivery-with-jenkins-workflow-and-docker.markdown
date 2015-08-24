---
layout: post
title: "Continuous Delivery with Jenkins workflow and Docker"
date: 2015-08-23 18:49
comments: true
categories: [Continuous Delivery, Jenkins, Jenkins workflow, maven, Docker, devops, test, en]
---

Recently Cloudbees releases the [CloudBees Docker Workflow Plugin](https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Workflow+Plugin) to make the integration of Docker with Jenkins workflows as easy as possible. Now, deploying a continuous delivery pipeline is (almost) straightforward. Here is a simple but comprehensive example.

<!-- more -->

__Disclaimer__: I'm using a maven project for this example because maven a tool I'm comfortable with. This post could be adapted to python, rails or whatever-you-want project with minor efforts.

First of all, we need to install the required plugins in Jenkins:

- Workflow: Aggregator
- CloudBees Docker Workflow

This sample workflow is simple and composed of 4 steps:

1. Build and unit tests
2. Build Docker image
3. Acceptance Tests
4. Push Docker image

Build and unit tests
====================

In a new Workflow job enter this script:

```groovy
node {
    /* Configure the JDK to use. 'JDK8' is the symbolic name under which the JDK
     * is defined in the global Jenkins configuration. */
    env.JAVA_HOME="${tool 'JDK8'}"

    stage 'Build'
    /* Clone the project from github */
    git url: 'https://github.com/jcsirot/atmosphere-calculator.git', branch: '0.1.0'
    /* Select the maven configuration. 'M3' is the symbolic name used the
     * global Jenkins configuration. */
    def mvnHome = tool "M3"
    /* Run maven: build and run the unit tests  */
    sh "${mvnHome}/bin/mvn clean package"
    /* This is the syntax for using a generic step. Here the test results are archived. */
    step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*.xml'])
}
```

This short script runs maven to build the jars and to execute the unit tests. Now we are ready to build the Docker image.

Build Docker image
==================

The CloudBees Docker Workflow Plugin provides a global variable `docker` which offers access to the common Docker functions in workflow scripts. For a comprehensive description of the plugin and the available commands, look at the [plugin guide](http://documentation.cloudbees.com/docs/cje-user-guide/docker-workflow.html).

To build the image we call `build` on the `docker` variable. Two parameters are passed: the image name (with the Docker notation `[registry/]image[:tag]`) and the directory where is located the `Dockerfile`.

```groovy
node {
    /* ... */
    stage 'Build Docker image'
    def image = docker.build('jcsirot/atmo-calc:snapshot', '.')
}
```

The call returns a handle on the built image so we can work with it.

Acceptance Tests
================

In order to execute the acceptance tests we wants to run a container from our newly built image. The `withRun` method can be invoked on the image handle. It is possible to pass the `docker run` parameters like port mapping or volumes configuration.

`withRun` also takes a code block. The container is started at the begining of the block, then the code in the block is executed and the container is stopped at the end of the block. Note that the block is executed on the Jenkins node, __not inside the container__. Use the `inside` method on the image handle to execute code inside the container.

```groovy
node {
    /* ... */
    stage 'Acceptance Tests'
    image.withRun('-p 8181:8181') {c ->
        sh "${mvnHome}/bin/mvn verify"
    }
    /* Archive acceptance tests results */
    step([$class: 'JUnitResultArchiver', testResults: '**/target/failsafe-reports/TEST-*.xml'])
}
```

Push Docker image
=================

The last step consists in pushing the image to a Docker registry. It can be done with the method `push`.

In order to configure the registry credentials, go the Jenkins Manager Credentials page. Add a new username/password entry and enter your registry login and password. Click on __Advanced__ to show the ID field and enter a unique identifier.

{% img center /images/posts/jenkins-docker-credentials-20150823.png 'Docker Hub Credentials' %}

The `withRegistry` method is also used to pass the registry URL and credentials ID configure above.

```groovy
node {
    /* ... */
    stage 'Push image'
    docker.withRegistry("https://registry.hub.docker.com", "docker-registry") {
        image.push()
    }
}
```

The image is pushed and, unless you pushed it to a custom registry, should be available on the [Docker hub](https://hub.docker.com/).

What's next?
============

This example is simple and far from being perfect. Feel free to share suggestions or questions in the comments.

- The project I used for this sample: [https://github.com/jcsirot/atmosphere-calculator](https://github.com/jcsirot/atmosphere-calculator)
- The workflow script: [https://gist.github.com/jcsirot/4de001d280998f27aa82](https://gist.github.com/jcsirot/4de001d280998f27aa82)
