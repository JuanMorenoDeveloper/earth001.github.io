---
title: 4 ways to improve our unit test assertions
date: 2020-08-10T23:34:35+00:00
author: Juan Moreno
layout: post
comments: true
permalink: /4-ways-to-improve-our-unit-test-assertions/
categories:
  - testing
  - best-practices
---
## Introduction

## 1. Don't use assertEquals

## 2. Use assertThat instead 

[Hamcrest](http://hamcrest.org/JavaHamcrest/)
The last version can be found in [Maven Central](https://search.maven.org/search?q=g:org.hamcrest%20AND%20a:hamcrest-core)

## 3. Use AssertJ 

[AssertJ](https://joel-costigliola.github.io/assertj/)
The last version can be found in [Maven Central](https://search.maven.org/search?q=g:org.assertj%20AND%20a:assertj-core)

Top frameworks like [Spring](https://github.com/spring-projects/spring-framework/blob/e190851aee827048346dc512f88833c8bcaab7fa/spring-core/spring-core.gradle#L68),  [Hibernate](https://github.com/hibernate/hibernate-orm/blob/20273b81ee623d74d4c3d8efed2e7f2ab2f79c4e/gradle/libraries.gradle#L30), also [JUnit 5](https://github.com/junit-team/junit5/blob/cfdf09aad5ed70fae210fe14fad6d6356f749242/dependencies/dependencies.gradle.kts#L24) already use it.

## 4. Write one assertion by test

## Conclusions