### Feat. 1 
The struct friends keeps track of the bool 'voted'. I implemented this feature with a modifier which validates the value of this variable. 
The 'doVote' function uses this modifier and can only be executed if the value of voted for that specific friend is still false (he has not already voted).

### Feat. 2

Again, I implemented this feature by adding new modifiers. For the check, that a restaurant is added only once I iterate over the list of restaurants and compare
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
Not implemented, but here's how I would do it. Add a new variable 'deadlineBlock'. In the startVote function I would set it to the current block + 135 (which is around 30min).
I would add a modifier to the 'doVote' function which only allows to vote if the deadline was not exceeded. The 'doVote' function has to check if the deadline is met and then set
the current stage to 'VOTE_CLOSED'.

### Feat. 5

I introduced a new bool variable 'stopped' which holds the state of the contract. By default it is set to false, meaning that the contract is running. 
The new function 'setStopped' allows only the manager to change the state of the contract. When 'stopped' is true every function is disabled.
Again, a new modifier 'whenNotStopped' makes sure of it.

### Feat. 6

I changed the usage of int variables to uint8 because the use less storage and for the purpose of the lab the values will not exceed the limit of 0...255.
Mappings are already in use instead of arrays, so I did not have to change these. In addition, I changed the initilization from the objects to the direct approach, which is 
again less gas consuming. I also added the immutable keyword to the manager address.

### Feat. 7

I added test cases, which check if a friend is added twice, a restaurant is added twice and if a friend voted twice. 
Moreover, I have a test which validates, that the 'setStopped' function can only be executed by the manager. Same goes for the 'endVote' function, there is also a test for this.
At last, I prove that no function can be called when the contract is stopped.

Added tests: 
-'Set restaurent twice should fail', 
-'Add friend twice should fail',
-'Vote twice should fail',
-'Set stopped by manager',
-'Test doVote when stopped should fail',
-'End vote in create stage should fail'

All tests were successful.

### Known issues
There are no knows issues.


### Github
Here is the link to my github repo: https://github.com/fabiizw/blockchain-appl-arch_lab1.git
