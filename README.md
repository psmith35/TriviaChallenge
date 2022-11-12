# Trivia Challenge

This iOS app allows a user to play trivia based on a chosen category and question difficulty level and saves the player's high score to a leaderboard.

## Features

- Selecting a Question Difficulty and Category
- Answering Questions and Scoring Points
- Resetting the Challenge
- Saving a High Score
- Leaderboard

## Tech Stack

- **Languages:** Swift

- **Software:** Xcode, Git

- **Frameworks:** UIKit, CoreData, Foundation

## API Reference

#### Get Session Token

```http
  GET /api_token.php?command=request
```

#### Reset Session Token

```http
  GET /api_token.php?command=reset&token={sessionToken}
```

| Parameter      | Type     | Description                           |
| :------------- | :------- | :------------------------------------ |
| `sessionToken` | `String` | **Required.** Session token to reset. |

#### Get Trivia Categories

```http
  GET /api_category.php
```

#### Get Trivia Questions

```http
  GET /api.php?amount={amount}&token={sessionToken}
  &category={category}&difficulty={difficulty}&encode=base64
```

| Parameter      | Type     | Description                                                  |
| :------------- | :------- | :------------------------------------------------------------| 
| `amount`       | `Int`    | **Required.** Amount of trivia questions to get.             |
| `sessionToken` | `String` | **Required.** Session token to use.                          |
| `category`     | `Int`    | **Required.** Trivia category to get questions from.         |
| `difficulty`   | `Int`    | **Required.** The difficulty of the trivia questions to get. |

## Screenshots

| Question Selection | Question Answering | Leaderboard |
| :----------------- | :----------------- | :---------- |
| ![App Screenshot](https://live.staticflickr.com/65535/52493701696_5b87a807ec_w.jpg) | ![App Screenshot](https://live.staticflickr.com/65535/52494255958_c0272250c6_w.jpg) | ![App Screenshot](https://live.staticflickr.com/65535/52494170420_027f5c29d7_w.jpg)|
