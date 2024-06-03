### Feat. 1 
The struct friends keeps track of the bool 'voted'. I implement this feature with a modifier which validates the value of this variable. 
The 'doVote' function uses this modifier and can only be executed if the value of voted for that specific friend is still false (he has not already voted).

### Feat. 2

Again I implemented this feature by adding new modifiers. For the check, that a restaurant is added only once I iterate over the list of restaurants and compare
them with the one, which the manager adds. For the friend check, I validate, if the address has already been added to the friends list. 
The 'addRestaurant' and 'addFriends' functions use these modifiers, respectivly.

Questions: Does some friend means same adress or same name? Are same names but differnt adresses allowed?

### Feat. 3

I introduced an enum which holds the stage values and a new variable 'currentStage', which keeps track of the current stage phase. By default this variable is set to 'CREATE'.
Again I implemented a new modifier which validates the current stage phase. I also added two new functions 'openVote' and 'endVote'. They are used for changing the currentStage variable.
Changes are only possible from stage 'CREATE' to 'VOTE_OPEN' to 'VOTE_CLOSED' or back to 'CREATE' in case one wants to add another restaurant/friend. The modifier 'inStage(Stage stage)' makes sure that this works properly. 
For every stage I made sure, that only a choosen set of funtions can be called (again added the 'inStage' modifier to these functions). 
For example, in the 'CREATE' stage one can execute the 'addFriends' function but not the 'doVote' function. 

Therefore, I could delete the 'voteOpen' variable and the corresponding modifier.

### Feat. 4

### Feat. 5

I introduced a new bool variable 'stopped' which holds the state of the contract. By default it is set to false, meaning that the contract is running. 
The new function 'setStopped' allows only the manager to change the state of the contract. When 'stopped' is true every function is disabled.
Again, a new modifier 'whenNotStopped' makes sure of it.
