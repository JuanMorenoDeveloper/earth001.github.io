---
title: How to validate dates in Java without exception handling
date: 2021-04-14T22:29:00-03:00
author: Juan Moreno
layout: post
comments: true
permalink: /validating-dates-in-java-without-exception-handling/
excerpt: 
background: '/img/'
categories:
  - 
---

# 1. Overview

As developers, input validation is a common task. We need to assure it to use in the business logic without or with fewer surprises ☺. In this tutorial, we'll explore how to validate `String` dates using the [Apache Commons library](https://commons.apache.org/), and using Exception Handling. 
    
# 2. Example

For this case, we'll need to check if an input as `String date is valid. To do that we have a specific format that our input needs to follow.

Let's start with interface:

```java
interface DateValidator {
  boolean isValid(String date);
}
```

In the following sections, we'll explore some ways how to implement it. 

# 3. Using Exceptions

Without adding external libraries to our project we can implement it using `LocalDate`'s `parse` method.

The [method's javadoc](https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/time/LocalDate.html#parse(java.lang.CharSequence,java.time.format.DateTimeFormatter)) says it has two inputs: the text represents the date, and the formatter to use. Also, it throws a [`DateTimeParseException`](https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/time/format/DateTimeParseException.html) when the text cannot be parsed.

```java
@Override
public boolean isValid(String date) {
  try {
    LocalDate.parse(date, formatter);
  } catch (DateTimeParseException e) {
    return false;
  }
  return true;
}
```
# References
https://ahdak.github.io/blog/effective-java-part-9/
https://dzone.com/articles/the-truth-of-java-exceptions-whats-really-going-on
http://tutorials.jenkov.com/java-performance/jmh.html#dead-code-elimination
https://nwcpp.org/october-2006.html
https://stackoverflow.com/questions/3589819/overhead-of-exception-handling-in-d/3590198#3590198
https://stackoverflow.com/questions/3744984/performance-when-exceptions-are-not-thrown-c
http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p0709r0.pdf
http://ithare.com/app-level-developer-on-std-error-exceptions-proposal-for-c-part-i-the-good/#rabbitref-DevSurvey0218
https://www.markdownguide.org/basic-syntax/
# 3.1 Exceptions

# 4. Using Apache Commons



# 5. Testing

# 6. Comparing implementations using JMH

# 7. Conclusion
