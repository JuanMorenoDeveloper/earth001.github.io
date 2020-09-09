---
title: 3 ways to improve our unit test assertions
date: 2020-09-09T00:15:09+03:00
author: Juan Moreno
layout: post
comments: true
permalink: /3-ways-to-improve-our-unit-test-assertions/
categories:
  - testing
  - best-practices
---
## Introduction

Usually, unit tests have 3 parts: Arrange, Act, and Assertion. The assertion is the test's verification part and, It has the responsibility to answer the question: Does have this test the behavior that we're looking for?

In this tutorial, we'll explore some alternatives to improve our test assertions to become more concise, powerful, and easy to read.

## Example

Let's start with a simple `BankAccount` class:

```java
class BankAccount {

  private final double balance;

  // Constructor, getter, equals & hashcode
}
```

Now, lets create a list of bank accounts: 

```java
//Arrange
var accounts = List
    .of(new BankAccount(100), new BankAccount(200),
        new BankAccount(300), new BankAccount(400),
        new BankAccount(500));
```

and filter it by a fixed amount balance, let's say 300:

```java
//Act
int limit = 300;
var result = accounts
    .stream()
    .filter(account -> account.getBalance() >= limit)
    .collect(Collectors.toList());
```
According to `limit`, when we filter the list, we'll get in `result` a new list with a size of 3.

At this point, we already accomplished the **arrange**, and the **act** parts, in the next sections we explore how to do the **assert** part.

## 1. Don't use `assertEquals`

An alternative to verify it is with the `assertEquals` method:

```java
assertEquals(result.size(), 3);
```

Don't get me wrong, `assertEquals` works great but lacks expressiveness, and we need to think carefully in which order we need to put the params, for example, what is the difference between:

```java
assertEquals(result.size(), 3);
```
and:
```java
assertEquals(3, result.size());
```

We can think is the same, actually, when the test is OK we'll get a green result.

Now, lets make the test fail changing the number 3 to 5.

```java
assertEquals(result.size(), 5);
``` 
in the first case we'll get:

```java
org.opentest4j.AssertionFailedError: 
Expected :3
Actual   :5
```
and in the second case:

```java
assertEquals(5, result.size());
```

we'll see:

```java
org.opentest4j.AssertionFailedError: 
Expected :5
Actual   :3
```

With these outputs I can't guess which is the problem; is it the expected value? or is it the calculation result?. 

When we work in a test suite with multiple unit tests it is very important to maintain the expressiveness to fix bugs and improve readability. 

## 2. Use `assertThat` instead 

An alternative option to `assertEquals` is `assertThat`. JUnit offers us the possibility of using a variety of [third-party assertion libraries](https://junit.org/junit5/docs/5.6.2/user-guide/#writing-tests-assertions-third-party) to enrich our matchers options.
 
An example of these matchers libraries is [Hamcrest](http://hamcrest.org/JavaHamcrest/). With Hamcrest we can rewrite our assertion part to something like this:
 
```java
assertThat(result, hasSize(3));
```

A key difference is expressiveness. Now, let's see what happen if change the size expected to 5:

```java
assertThat(result, hasSize(5));
```

We'll get a more descriptive error:

```
java.lang.AssertionError: 
Expected: a collection with size <5>
     but: collection size was <3> 
```

The last Hamcrest version can be found in [Maven Central](https://search.maven.org/search?q=g:org.hamcrest%20AND%20a:hamcrest-core).

## 3. Use AssertJ 

Another powerful assertion library is [AssertJ](https://joel-costigliola.github.io/assertj/), actually, top frameworks like [Spring](https://github.com/spring-projects/spring-framework/blob/e190851aee827048346dc512f88833c8bcaab7fa/spring-core/spring-core.gradle#L68), [Hibernate](https://github.com/hibernate/hibernate-orm/blob/20273b81ee623d74d4c3d8efed2e7f2ab2f79c4e/gradle/libraries.gradle#L30), and [JUnit 5](https://github.com/junit-team/junit5/blob/cfdf09aad5ed70fae210fe14fad6d6356f749242/dependencies/dependencies.gradle.kts#L24) are using it.

With the AssertJ fluent syntax, we can check the size of the list and add extra verifications; for example that the `BackAccount` with 100 balance isn't present:

```java
assertThat(result)
    .hasSize(3)
    .doesNotContain(new BankAccount(100));
```

and the error message (if we change the size expected to 5) is very helpful:

```java
java.lang.AssertionError: 
Expected size:<5> but was:<3> in:
<[BankAccount{balance=300.0},
    BankAccount{balance=400.0},
    BankAccount{balance=500.0}]>
```

The last AssertJ's version can be found in [Maven Central](https://search.maven.org/search?q=g:org.assertj%20AND%20a:assertj-core).

## Conclusions

In this tutorial, we saw how to use different assertions libraries to improve our unit tests to become more expressive, easy to read and maintain.

The full code can be found over on [Github](https://github.com/JuanMorenoDeveloper/3-ways-to-improve-our-unit-test-assertions).