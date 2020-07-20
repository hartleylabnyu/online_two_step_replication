var block_trials = 50; //total number of trials in each block
var transprob = 0.7; //probability of 'correct' transition

var right_key = 48; //0 at top of keyboard
var left_key = 49; //1 at top of keyboard

var randomize_side = false; //whether we should further randomize robot sides

//subject level display orders for when we aren't randomizing every trial
var rocket_sides = (Math.random() < .5);
var prac_rocket_sides = (Math.random() < .5);
var red_display_order = (Math.random() < .5);
var purple_display_order = (Math.random() < .5);
var green_display_order = (Math.random() < .5);
var yellow_display_order = (Math.random() < .5);

var moneytime = 1000; //1000 according to Decker 2016;
var isitime = 1000; //1000 according to Decker 2016;
var choicetime = 3000; //3000 according to Decker 2016;
var box_moving_time = 90; // from comment in matlab code
var ititime = 1000; ///1000 according to Decker 2016;

var num_blocks = 4;

var reward_instructions_payoff = ['.8', '.8', '.8', '.8'];
var instructions_payoff = ['.9', '.1', '.9', '.1']; 

var red_planet_first_rocket = (Math.random() < 0.5);

var probability_file = "fixed/masterprob4.csv";
var practice_probability_file = "fixed/masterprobtut.csv";

var reward_string = "images/t.png";
var null_string = "images/nothing.png";

var practice_reward = 0,
    real_reward = 0;

var practice_pressing_idx = 5;
var practice_pressing_num = 4; // 4 trials to practice selecting alien
var practice_reward_idx = 10 + practice_pressing_num;
var practice_reward_num = 10; // 10 trials to practice asking alien for treasure
var practice_stochastic_idx = 17 + practice_pressing_num + practice_reward_num;
var practice_stochastic_num = 10; // 10 trials to practice choosing between aliens
var practice_game_idx = 34 + practice_pressing_num + practice_reward_num + practice_stochastic_num;
var practice_game_num = 20; // 20 trials to practice full game

var image_path = "images/";
var image_strings =
["alien1_a1.png","alien4_sp.png","tutalien1_a2.png","tutalien4_deact.png",
"alien1_a2.png","blackbackground.jpg","tutalien1_deact.png","tutalien4_norm.png",
"alien1_deact.png","earth.jpg","tutalien1_norm.png","tutalien4_sp.png",
"alien1_norm.png","nothing.png","tutalien1_sp.png","tutgreenplanet.jpg",
"alien1_sp.png","purpleplanet.jpg",
"alien2_a1.png","redplanet1.jpg","tutalien2_a1.png","tutrocket1_a1.png",
"alien2_a2.png","rocket1_a1.png","tutalien2_a2.png","tutrocket1_a2.png",
"alien2_deact.png","rocket1_a2.png","tutalien2_deact.png","tutrocket1_deact.png",
"alien2_norm.png","rocket1_deact.png","tutalien2_norm.png","tutrocket1_norm.png",
"alien2_sp.png","rocket1_norm.png","tutalien2_sp.png","tutrocket1_sp.png",
"alien3_a1.png","rocket1_sp.png",
"alien3_a2.png","rocket2_a1.png","tutalien3_a1.png","tutrocket2_a1.png",
"alien3_deact.png","rocket2_a2.png","tutalien3_a2.png","tutrocket2_a2.png",
"alien3_norm.png","rocket2_deact.png","tutalien3_deact.png","tutrocket2_deact.png",
"alien3_sp.png","rocket2_norm.png","tutalien3_norm.png","tutrocket2_norm.png",
"alien4_a1.png","rocket2_sp.png","tutalien3_sp.png","tutrocket2_sp.png",
"alien4_a2.png","t.png","tutyellowplanet.jpg",
"alien4_deact.png","tutalien4_a1.png",
"alien4_norm.png","tutalien1_a1.png","tutalien4_a2.png", "fish.png", "tiger.png", 
"shark.png", "turtle.png", "replay.png"];

var all_images = image_strings.map(function(data) {return image_path + data;});

// audio to preload
quiz_audio = ['audio/quiz/Q1_Correct.wav', 'audio/quiz/Q1_Incorrect.wav',
'audio/quiz/Q2_Correct.wav', 'audio/quiz/Q2_Incorrect.wav',
'audio/quiz/Q3_Correct.wav', 'audio/quiz/Q3_Incorrect.wav',
'audio/beep_loop.wav', 'audio/instructions/treasure_feedback.wav',
'audio/instructions/break_1.wav', 'audio/instructions/break_2.wav',
'audio/instructions/break_3.wav', 'audio/instructions/query.wav',
'audio/instructions/end_of_task.wav'];




/** Global position variables **/

var height = window.innerHeight;
var width = window.innerWidth;

//scaling for window sizes; if the participant or researcher resizes things will break!
if (window.innerWidth / window.innerHeight < 1.34) {
    var picture_height = window.innerWidth / 1.34;
    var picture_width = window.innerWidth;
} else {
    var picture_height = window.innerHeight;
    var picture_width = window.innerHeight * 1.34;
}
var monster_size = picture_height * 300 / 758; //scaling from original to picture
var reward_size = picture_height * 75 / 758; //similarly for the reward

var x_center = width / 2;
var y_center = height / 2;

var choice_y = y_center + 0.22 * picture_height - monster_size / 2 ;
var choice_x_right = x_center + 0.25 * picture_width - monster_size / 2;
var choice_x_left = x_center - 0.25 * picture_width - monster_size / 2;

var chosen_y = y_center - 0.06 * picture_height - monster_size / 2;
var chosen_x = x_center - monster_size / 2;

var reward_y = y_center - 0.06 * picture_height - reward_size / 2 - monster_size / 2;
var reward_x = x_center - reward_size / 2;

var text_start_y = y_center - 0.2 * picture_height;
var instructions_text_start_y = y_center - 0.4 * picture_height;
var text_start_x = x_center - 0.49 * picture_width;
var font_size = picture_height * 25 / 758;

var instructions_backgrounds = ["images/blackbackground.jpg", "images/earth.jpg", "images/tutgreenplanet.jpg", "images/blackbackground.jpg", "images/tutyellowplanet.jpg", "images/blackbackground.jpg", "images/tutgreenplanet.jpg", "images/tutgreenplanet.jpg", "images/blackbackground.jpg", "images/blackbackground.jpg", "images/earth.jpg", "images/tutgreenplanet.jpg", "images/tutyellowplanet.jpg", "images/earth.jpg", "images/earth.jpg", "images/blackbackground.jpg"];

//*** START IMAGES for instruction pages**//
//**************************************//

var left_images = [];
var right_images = [];
var center_images = [];
var reward_images = [];
var audio_files = [];
var button_images = [];
var i,
    j,
    curr_instructs;

for (i = 0; i < instructions.length; i += 1) {
    curr_instructs = instructions[i];
    left_images[i] = [];
    right_images[i] = [];
    reward_images[i] = [];
    center_images[i] = [];
    audio_files[i] = [];
    button_images[i] = [];
    for (j = 0; j < curr_instructs.length; j += 1) {
        left_images[i][j] = null;
        right_images[i][j] = null;
        center_images[i][j] = null;
        reward_images[i][j] = null;
        button_images[i][j] = "images/button.jpeg"
    }
}

reward_images[3][0] = reward_string;
reward_images[3][1] = null_string;

center_images[4][0] = "images/tutalien3_norm.png";
center_images[4][1] = "images/tutalien3_norm.png";
center_images[9][0] = "images/tutalien2_norm.png";

right_images[1][0] = "images/tutrocket1_norm.png";
left_images[1][0] = "images/tutrocket2_norm.png";

right_images[2][0] = "images/tutalien1_norm.png";
left_images[2][0] = "images/tutalien2_norm.png";
right_images[2][1] = "images/tutalien1_norm.png";
left_images[2][1] = "images/tutalien2_norm.png";
right_images[2][2] = "images/tutalien1_norm.png";
left_images[2][2] = "images/tutalien2_norm.png";

right_images[6][0] = "images/tutalien1_norm.png";
right_images[7][0] = "images/tutalien2_norm.png";

left_images[6][0] = "images/tutalien2_norm.png";
left_images[7][0] = "images/tutalien1_norm.png";

right_images[13][0] = "images/tutrocket1_norm.png";
right_images[13][1] = "images/tutrocket1_norm.png";
right_images[14][0] = "images/tutrocket1_norm.png";
right_images[14][1] = "images/tutrocket1_norm.png";
right_images[14][2] = "images/tutrocket1_norm.png";
right_images[14][3] = "images/tutrocket1_sp.png";
right_images[14][4] = "images/tutrocket1_norm.png";
right_images[14][5] = "images/tutrocket1_norm.png";

left_images[13][0] = "images/tutrocket2_norm.png";
left_images[13][1] = "images/tutrocket2_norm.png";
left_images[14][0] = "images/tutrocket2_norm.png";
left_images[14][1] = "images/tutrocket2_norm.png";
left_images[14][2] = "images/tutrocket2_norm.png";
left_images[14][3] = "images/tutrocket2_sp.png";
left_images[14][4] = "images/tutrocket2_norm.png";
left_images[14][5] = "images/tutrocket2_norm.png";









//*** END IMAGES for instruction pages**//
//**************************************//
