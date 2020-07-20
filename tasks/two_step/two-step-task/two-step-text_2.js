/** Texts **/

var id_prompt = 'Please enter your subject ID';
var query_text = 'Which spaceship went mostly to the red planet?';
var break_text_1 = 'Great job so far! You have completed 1 out of 4 rounds. <br> You may now take a break. <br>  Press the button when you are ready for the next round.';
var break_text_2 = 'Awesome! You are halfway through the game. <br>  You may now take a break. <br>  Press the button when you are ready for the next round.';
var break_text_3 = 'Almost done! Just 1 more round to go. <br> You may now take a break. <br>  Press the button when you are ready for the next round.';

var instructions = [];
var audio_instructions = [];

//*** START Text for instruction pages**//
//**************************************//
//black background
instructions[0] = [
    ['Please listen to the instructions and read each page carefully.', 'When you are ready to go to the next page,', 'click on the red circle on the bottom right so that it turns green.', 'Then, press the space bar.']
];


//rocket background
instructions[1] = [
    ['In this game, you will be taking a spaceship from earth', 'to look for space treasure on two different planets.']
];


//alien background
instructions[2] = [
    ['Each planet has two aliens on it. ', ' And each alien has its own space treasure mine.'],
    ['On each planet, you will pick one alien to ask for space treasure. ', 'These aliens are nice, so if an alien just brought treasure ', ' up from the mine, it will share it with you.'],
    ['For each choice, choose the left alien by pressing the 1 key ', ' and the right alien by pressing the 0 key. ', 'The choice you make will be highlighted.', 'Click the red circle and press the space bar to move to the next page.', 'Then try practicing a few times by pressing 1 and 0.']
];

// black background
instructions[3] = [
    ['After you choose an alien, you will find out whether you got treasure.  ', ' Which looks like this.   '],
    ['If the alien couldn\'t bring treasure up this time you\'ll see an empty circle.  ', ' Which looks like this.   '],
    ['If an alien has a good mine that means it can easily dig up space treasure ', ' and it will be very likely to have some to share.  '],
    ['It might not have treasure EVERY time you ask, but it will most of the time. ', ' Another alien might have a bad mine that is hard to dig through at the moment, ', ' and won\'t have treasure to share most times you ask.']
];

//yellow alien
instructions[4] = [
    ['For example, the alien on the yellow planet has a good mine right now. ', 'Click the red circle and press the space bar to move to the next page. ', 'Then, try asking it for treasure 10 times by pressing 1.'],
    ['See, this alien shared treasure most of the times you asked, ', ' but not every time.  ']
];

//black background
instructions[5] = [
    ['Every alien has treasure in its mine, but they can\'t share every time. ', ' Some will be more likely to share because it is easier to dig right now. ']
];

// one right
instructions[6] = [
    ['Next, you can choose between two aliens ', ' and try to figure out which one has more treasure to share.', '']
];

//one left
instructions[7] = [
   ['...and sometimes come up on the left.']
];

//black
instructions[8] = [
    ['Which side an alien appears on does not matter. ', ' For instance, left is not luckier than right.'],
    ['You can practice choosing now. ', ' You have 20 choices to try to figure out which alien has a good mine.  '],
    ['Remember, key 1 is for the left alien, and key 0 is for the right alien.  ', ' Click the red circle and then press any key to start.']
];

//black
instructions[9] = [
    ['Good. You might have learned that this alien had treasure more often. ', ' Also, even if this alien had a better mine, ', ' you couldn\'t be sure if it had treasure all the time.   '],
    ['Each alien is like a game of chance, you can never be sure but you can guess. '],
    ['The treasure an alien can give will change during the game. '],
    ['Those with a good mine might get to a part of the mine that is hard to dig. ', ' Those with little to share might find easier treasure to dig. ', ' Any changes in an alien\'s mine will happen slowly, ', ' so try to focus to get as much treasure as possible.'],
    ['While the chance an alien has treasure to share changes over time, ', ' it changes slowly.  '],
    ['So an alien with a good treasure mine right now will stay good for a while. ', ' To find the alien with the best mine at each point in time, ', ' you must concentrate. ']
];

//rocket
instructions[10] = [
    ['Now that you know how to pick aliens, you can learn to play the whole game. ', ' You will travel from earth to one of two planets.']
];

//green
instructions[11] = [
    ['Here is the green planet']
];

//yellow
instructions[12] = [
    ['And here is the yellow planet']
];

//rocket
instructions[13] = [
    ['First you need to choose which spaceship to take.  ', ' The spaceships can fly to either planet, but one will fly mostly ', ' to the green planet, and the other mostly to the yellow planet.'],
    ['The planet a spaceship goes to most won\'t change during the game. ', ' Pick the one that you think will take you to the alien ', ' with the best mine, but remember, sometimes you\'ll go to the other planet!']
];

//rocket
instructions[14] = [
    ['Let\'s practice before doing the full game.  ', ' Remember, you want to find as much space treasure as you can ', ' by asking an alien to share with you.'],
    ['The aliens share somewhat randomly, ', ' but you can find the one with the best mine at any point in the game ', ' by asking it to share!  '],
    ['How much bonus money you make is based on how much space treasure you find. ', ' This is just a practice round of 20 flights, you\'re not playing for money now.'],
    ['You will have three seconds to make each choice.  If you are too slow, ', ' you will see a large X appear on each rocket or alien and that choice will be over.'],
    ['Don\'t feel rushed, but please try to make a choice every time.'],
    ['Good luck! Remember that 1 selects left and 0 selects right.']
];

// //black
instructions[15] = [
    ['That is the end of the practice game.  ', ' Click the red button. Then press any key to see how you did...'],
];

instructions[16] = [
    ['Okay, that is nearly the end of the tutorial!  ', ' In the real game, the planets, aliens, and spaceships will be new colors, ', ' but the rules will be the same.  ', ' The game is hard, so you will need to concentrate, ', ' but don\'t be afraid to trust your instincts. ', ' Here are three hints on how to play the game.'],
    ['Hint #1:  ', ' Remember which aliens have treasure. How good a mine is changes slowly, ', ' so an alien that has a lot of treasure to share now, ', ' will probably be able to share a lot in the near future. '],
    ['Hint #2:  ', ' Remember, each alien has its own mine.  Just because one alien has a bad ', ' mine and can\'t share very often, does not mean another has a good mine.  ', ' Also, there are no funny patterns in how an alien shares, ', ' like every other time you ask, or depending on which spaceship you took. ', ' The aliens are not trying to trick you.'],
    ['Hint #3:  ', ' The spaceship you choose is important because often an alien on one planet ', ' may be better than the ones on another planet. ', ' You can find more treasure by finding the spaceship ', ' that is most likely to take you to right planet.'],
];

instructions[17] = [
    ['Now it\'s time to make sure you know how to play.  ', 'Please respond TRUE or FALSE to the questions on the next few pages.']
];

instructions[18] = [
    ['OK! Now you know how to play.  ', ' In the real game we\'ll count how many pieces of space treasure ', ' you find and show you at the end. ', ' Ready?  Now its time to play the game!  Good luck space traveler!']
];




//*** END Text for instruction pages**//
//**************************************//

// ADD AUDIO //

audio_instructions[0] = [["audio/instructions/I_0.1.wav"]];
audio_instructions[1] = [["audio/instructions/I_1.1.wav"]];


audio_instructions[2] = [
    ['audio/instructions/I_2.1.wav'],
    ['audio/instructions/I_2.2.wav'],
    ['audio/instructions/I_2.3.wav']
];


audio_instructions[3] = [
    ["audio/instructions/I_3.1.wav"],
    ["audio/instructions/I_3.2.wav"],
    ["audio/instructions/I_3.3.wav"],
    ["audio/instructions/I_3.4.wav"]
];

audio_instructions[4] = [
    ["audio/instructions/I_4.1.wav"],
    ["audio/instructions/I_4.2.wav"]
];

audio_instructions[5] = [
    ["audio/instructions/I_5.1.wav"]
];

audio_instructions[6] = [
    ["audio/instructions/I_6.1.wav"]
];

audio_instructions[7] = [
    ["audio/instructions/I_7.1.wav"]
];

audio_instructions[8] = [
    ["audio/instructions/I_8.1.wav"],
    ["audio/instructions/I_8.2.wav"],
    ["audio/instructions/I_8.3.wav"]
];

audio_instructions[9] = [
    ["audio/instructions/I_9.1.wav"],
    ["audio/instructions/I_9.2.wav"],
    ["audio/instructions/I_9.3.wav"],
    ["audio/instructions/I_9.4.wav"],
    ["audio/instructions/I_9.5.wav"],
    ["audio/instructions/I_9.6.wav"]
];

audio_instructions[10] = [
    ["audio/instructions/I_10.1.wav"]
];

audio_instructions[11] = [
    ["audio/instructions/I_11.1.wav"]
];

audio_instructions[12] = [
    ["audio/instructions/I_12.1.wav"]
];

audio_instructions[13] = [
    ["audio/instructions/I_13.1.wav"],
    ["audio/instructions/I_13.2.wav"]
];

audio_instructions[14] = [
    ["audio/instructions/I_14.1.wav"],
    ["audio/instructions/I_14.2.wav"],
    ["audio/instructions/I_14.3.wav"],
    ["audio/instructions/I_14.4.wav"],
    ["audio/instructions/I_14.5.wav"],
    ["audio/instructions/I_14.6.wav"]
];

audio_instructions[15] = [
    ["audio/instructions/I_15.1.wav"]
];

audio_instructions[16] = [
    ["audio/instructions/I_16.1.wav"],
    ["audio/instructions/I_16.2.wav"],
    ["audio/instructions/I_16.3.wav"],
    ["audio/instructions/I_16.4.wav"],
];

audio_instructions[17] = [
    ["audio/instructions/I_17.1.wav"]
];

audio_instructions[18] = [
    ["audio/instructions/I_18.1.wav"]
];

console.log(instructions)
console.log(audio_instructions)

