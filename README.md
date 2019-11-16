# GOMOKU-FPGA


## CSC258 Final Project Proposal

 

### Team Information

1. Team Member One  
   First Name: Tingfeng  
   Last Name: Xia  
   Student Number: 1003780884  
   Email Address: tingfeng.xia@mail.utoronto.ca  

 

2. Team Member Two  
   First Name: Yuqian  
   Last Name: Xie  
   Student Number: 1004955293  
   Email Address: yuqian.xie@mail.utoronto.ca  
   
3. Team Member Three  
   First Name: Chang  
   Last Name: Yuan  
   Student Number: 1004825184  

### Project Milestones

Name of the project: Gomoku
One paragraph description of the project: 
Gomoku is a well known 2 player board game where player 1 uses a white token and player 2 uses a black token. On the game board, the first player that has five consecutive tokens connected (could be horizontal, vertical or slanted) wins the game.


#### Milestone I . 

Display the empty board on the screen through VGA cable. Go over the resources posted on quercus regarding keyboard control and then implement the keyboard control. Find resources for the while/black token and the game board.   

 

 

#### Milestone II . 

Users should be able to move the pointer around on the screen using the arrow keys on the keyboard.  Users should also be able to put the token down (using the enter key on the keyboard) on any valid position on the game board. Notice that tokens have alternating color, meaning that if the last token put down was a white one the next one should be black.   

 

#### Milestone III . 

Check if the game has been won or not. If won, by which player. Display a message for who won the game. Make the hex display various game stats, including the current player identified by the player’s number.   

 

 

### Project Motivations . 

- How does this project relate to material covered in CSC258?  

Gomoku is a board game where each step is built upon previous choices which means to implement this game, we will need to store states. We will need to build a sequential circuit with registers. At the same time, the circuit will need to be clocked, which is again, related to CSC258 material. The game state(game board) will be displayed on a screen through a VGA cable and this is related to the Lab7 material. We will also use the hex display to show some of the stats for the ongoing game. 

 

 

- What's cool about this project (to CSC258 students and non-CSC258 students)?   

For both of our team members, Gomoku is our favorite childhood board game. It has simple-to-understand rules, yet it has infinite possibilities in strategies and game play. As CSC258 students, it would be cool to reproduce this game that we all loved using knowledge we learnt. For a non-CSC258 student, this still would be interesting to have a match and play against their friends! 

 

 

- Why does the idea of working on this appeal to you personally?

Nowadays, there are so many games out on the market but most of them doesn’t enhance the players thinking skills. However, the Gomoku game is different! It requires careful thinking and thorough planning throughout the gameplay which is beneficial for us. In this way, we can have fun with our friends and enhance ourselves at the same time!
