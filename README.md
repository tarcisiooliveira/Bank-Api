# Bank API ![actions](https://github.com/tarcisiooliveira/bank_api/workflows/actions/badge.svg) [![Coverage Status](https://coveralls.io/repos/github/tarcisiooliveira/Bank-Api/badge.svg?branch=master)](https://coveralls.io/github/tarcisiooliveira/Bank-Api?branch=master)


## Introduction

The Api is organized into the contexts below:

## Users

- Sign up new users
> This feature creates an user and their account. When creating the account the user receives 100000 cents (hundred thousand cents). The API works with the monetary value in cents
- Sign in users.
> This feature requires the user's credentials (email and password), if the credentials are valid, the response will have a token that allow the access to protected resources


## Transactions

- Transfer
> This feature transfers money from the logged in user's account to another account. When transferring money, `transfer` type transaction is created. Linkeds respectively to the user who send the money and the one who received the transfer. For the transaction to happen it is necessary to have the amount of money available in your account.
- Withdraw
> This feature allows the logged in user to withdraw money from their account. When withdrawing money, a `withdraw` type transaction is created. The user must have sufficient balance in his account to cover the withdrawal amount. After operation, an email will be send with proof.


## Admins

- Sign up new Admin
> This feature creates an administrator. They have access to the transaction report
- Sign in Admin
> This feature requires that the administrator's credentials (email and password), if the credentials are valid, the response will have a token that allow the access to protected resources
- report
> This feature returns the sum of all transactions for a period

## Setup

There is a Makefile that call some docker commands to start the application and test it.

To start the application:
> make up

To start application in iterative mode:
> make up-iterative

To run application tests the application:
> make test

To stop the containers:
> make down

## Deployment

The api use the github actions for CI/CD and is hosted at https://gigalixir.com/ on a free plan.
The public endpoint is: https://bankstone.gigalixirapp.com/api/v1

An api example of utilization is provided here:

[File postman](https://github.com/tarcisiooliveira/Bank-Api/blob/master/Postman)\
[File environment developer](https://github.com/tarcisiooliveira/Bank-Api/blob/master/postman/development.enviroment.json)\
[File environment production](https://github.com/tarcisiooliveira/Bank-Api/blob/master/postman/production.environment.json)

The postman files above provide a development and production environment, if you want to use the local environment, just use the "development" environment variable or use the "production" environment variable to consume the public endpoint that is hosted on the gigalixir. If you have difficulty importing files into postman: https://learning.postman.com/docs/getting-started/importing-and-exporting-data/
