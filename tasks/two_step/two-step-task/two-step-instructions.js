var t_i,
    i,
    j,
    curr_page,
    curr_side;

function create_instructions(image, texts, audio_files, sect_right_texts, sect_left_texts, sect_center_texts, sect_reward_texts) {
    'use strict';
    var instruction_pages = [];
    for (t_i = 0; t_i < texts.length; t_i += 1) {
        curr_page  = {
            type: 'd3-instructions',
            stimulus: image,
            right_text: sect_right_texts[t_i],
            left_text: sect_left_texts[t_i],
            center_text: sect_center_texts[t_i],
            reward_string: sect_reward_texts[t_i],
            choices: jsPsych.ALL_KEYS,
            prompt: texts[t_i],
            audio_stimulus: audio_files[t_i]
        }; 
        instruction_pages.push(curr_page);
    }
    return instruction_pages;
}

// Create instructions
var curr_instructions = [];
for (i = 0; i < instructions.length; i += 1) {
    curr_instructions = curr_instructions.concat(create_instructions(instructions_backgrounds[i], instructions[i], audio_instructions[i], right_images[i], left_images[i], center_images[i], reward_images[i], button_images[i]));
}


// INSERT PRACTICE 

// insert 4 selection practice trials on instructions page 5 
for (i = 0; i < (practice_pressing_num - 1); i += 1) {
    curr_instructions.splice(practice_pressing_idx, 0, {
        type: 'd3-animate-choice',
        timeout: false,
        choices: [left_key, right_key],
        planet_text: "images/tutgreenplanet.jpg",
        right_text: "images/tutalien1",
        left_text: "images/tutalien2",
        prompt: ["Now try another one"],
        trial_duration: choicetime
    });
}
curr_instructions.splice(practice_pressing_idx, 0, {
    type: 'd3-animate-choice',
    timeout: false,
    choices: [left_key, right_key],
    planet_text: "images/tutgreenplanet.jpg",
    right_text: "images/tutalien1",
    left_text: "images/tutalien2",
    trial_duration: choicetime
});

// insert 10 treasure asking practice trials
for (i = 0; i < practice_reward_num; i += 1) {
    curr_instructions.splice(practice_reward_idx, 0, {
        type: 'd3-animate-choice',
        timeout: false,
        trial_row: reward_instructions_payoff,
        choices: [left_key, right_key],
        planet_text: "images/tutyellowplanet.jpg",
        right_text: function() {if (curr_side === true) {return "images/tutalien3";} return null;},
        left_text: function() {if (curr_side === true) {return null;} return "images/tutalien3";},
        trial_duration: choicetime
    });
}

// insert 10 asking green aliens for reward trials
for (i = 0; i < practice_stochastic_num; i += 1) {
    curr_instructions.splice(practice_stochastic_idx, 0, {
        type: 'd3-animate-choice',
        timeout: false,
        trial_row: instructions_payoff,
        choices: [left_key, right_key],
        planet_text: "images/tutgreenplanet.jpg",
        right_text: "images/tutalien1",
        left_text: "images/tutalien2",
        trial_duration: choicetime
    });
}

console.log(curr_instructions)

//remove the instructions about aliens on either side
curr_instructions.splice(27,3) 


// initialize connection with Pavlovia
curr_instructions.splice(0, 0,  {
        type: "pavlovia",
        command: "init"
        });

// Insert audio test trials
curr_instructions.splice(1, 0, {
    type: 'html-keyboard-response',
    choices: jsPsych.ALL_KEYS,
    stimulus: 'Welcome! Press the space bar to begin.',
});

curr_instructions.splice(2, 0, {
    type: 'audio-keyboard-response',
    stimulus: 'audio/beep_loop.wav',
    choices: jsPsych.ALL_KEYS,
    prompt: 'You should now hear beeps playing. If so, press the space bar to proceed to the audio test.',
});


curr_instructions.splice(3, 0, {
    type: 'audio-button-response',
    stimulus: 'audio/fish.mp3',
    choices: ['repeat', 'fish', 'tiger', 'turtle', 'shark'],
    correct_answer: 1,
    prompt: 'Click on the word that you just heard.',
    incorrect_prompt: 'Incorrect, please adjust your volume and try again.',
    margin_vertical: '40px',
    margin_horizontal: '10px',
    button_html:[
        '<img src="images/replay.png" height="200px" width="200px"/>',
        '<img src="images/fish.png" height="200px" width="200px"/>',
        '<img src="images/tiger.png" height="200px" width="200px"/>',
        '<img src="images/turtle.png" height="200px" width="200px"/>',
        '<img src="images/shark.png" height="200px" width="200px"/>'
    ],
    post_trial_gap: 1000
});


curr_instructions.splice(4, 0, {
    type: 'audio-button-response',
    stimulus: 'audio/tiger.mp3',
    choices: ['repeat', 'turtle', 'shark', 'fish', 'tiger'],
    correct_answer: 4,
    prompt: 'Again, click on the word that you just heard.',
    incorrect_prompt: 'Incorrect, please adjust your volume and try again.',
    margin_vertical: '40px',
    margin_horizontal: '10px',
    button_html:[
        '<img src="images/replay.png" height="200px" width="200px"/>',
        '<img src="images/turtle.png" height="200px" width="200px"/>',
        '<img src="images/shark.png" height="200px" width="200px"/>',
        '<img src="images/fish.png" height="200px" width="200px"/>',
        '<img src="images/tiger.png" height="200px" width="200px"/>'
    ],
    post_trial_gap: 1000
});

// add full screen after audio test
curr_instructions.splice(5, 0, {
    type: 'fullscreen', 
    message: '<p> Press start to enter full-screen mode and start the game. </p>',
    button_label: 'Start',
    fullscreen_mode: true});