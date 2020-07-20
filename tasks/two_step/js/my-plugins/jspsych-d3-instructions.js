/**
 * d3-instructions
 * Similar to other two-step task d3 plugins, sizes of pictures are global variables
 * VF 8/2019
 * KN added audio 4/22/20
 **/

jsPsych.plugins["d3-instructions"] = (function() {

  var plugin = {};

  jsPsych.pluginAPI.registerPreload('d3-instructions', 'audio_stimulus', 'audio');

  plugin.info = {
    name: 'd3-instructions',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Stimulus',
        default: null,
        description: 'The image to be displayed'
      },
      right_text: {
        type: jsPsych.plugins.parameterType.STRING,
        default: null,
        array: false
      },
      left_text: {
        type: jsPsych.plugins.parameterType.STRING,
        default: null,
        array: false
      },
      center_text: {
        type: jsPsych.plugins.parameterType.STRING,
        default: null,
        array: false
      },
      reward_string: {
        type: jsPsych.plugins.parameterType.STRING,
        default: null,
        array: false
      },
      choices: {
        type: jsPsych.plugins.parameterType.KEYCODE,
        array: true,
        pretty_name: 'Choices',
        default: jsPsych.ALL_KEYS,
        description: 'The keys the subject is allowed to press to respond to the stimulus.'
      },
      prompt: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Prompt',
        default: null,
        description: 'Any content here will be displayed below the stimulus.'
      },
      response_ends_trial: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Response ends trial',
        default: false,
        description: 'If true, trial will end when subject makes a response.'
      },
      button_clicked: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Button state',
        default: false,
        description: 'state of button.'
      },
      audio_stimulus: {
        type: jsPsych.plugins.parameterType.AUDIO,
        pretty_name: 'Audio stimulus',
        default: undefined,
        description: 'The audio to be played.'
      },
      trial_ends_after_audio: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Trial ends after audio',
        default: false,
        description: 'If true, then the trial will end as soon as the audio file finishes playing.'
      },
    }
  }

  plugin.trial = function(display_element, trial) {

    // display stimulus
    new_html='<div id="container" class="exp-container"></div>';
    display_element.innerHTML = new_html;

    var move_possible = true;

    var svg = d3.select("div#container")
      .append("svg")
      .attr("preserveAspectRatio", "xMinYMin meet")
      .attr("viewBox", "0 0 " + width + " " + height)
      .classed("svg-content", true);


    if (trial.stimulus !== null){
    var main_image = svg.append("svg:image")
        .attr('width', width)
        .attr('height', height)
        .attr("xlink:href", trial.stimulus)}

    if (trial.right_text !== null){
      var right_image = svg.append("svg:image")
        .attr('class', 'right')
        .attr('x', choice_x_right)
        .attr('y', choice_y)
        .attr('width', monster_size)
        .attr('height', monster_size)
        .attr("xlink:href", trial.right_text)}

    if (trial.reward_string !== null){
      var reward_image = svg.append("svg:image")
        .attr('x', x_center-reward_size/2)
        .attr('y', choice_y)
        .attr('width', reward_size)
        .attr('height', reward_size)
        .attr("xlink:href", trial.reward_string);
      }

    if (trial.left_text !== null){
    var left_image = svg.append("svg:image")
        .attr('x', choice_x_left)
        .attr('y', choice_y)
        .attr('width', monster_size)
        .attr('height', monster_size)
        .attr("xlink:href", trial.left_text)}

    if (trial.center_text !== null) {
      var center_image = svg.append("svg:image")
          .attr('x', x_center-monster_size/2)
          .attr('y', choice_y)
          .attr('width', monster_size)
          .attr('height', monster_size)
          .attr("xlink:href", trial.center_text) }

    var button_image = svg.append("svg:circle")
        .attr('r', 25)
        .attr('cx', choice_x_right + monster_size)
        .attr('cy', choice_y + monster_size - 100)
        .style("stroke", "black")
        .style("fill", "red")
        .on("click", function() {trial.button_clicked = true; console.log(trial.button_clicked);
          d3.select(this).style("fill", "green");
          d3.select(this).style("stroke", "black");
        })

  
    // add prompt
    if (trial.prompt !== null){
      //inspired by Mike Bostock
      // https://bl.ocks.org/mbostock/7555321
      var lineNumber = 0,
      lineHeight = 1.1, // ems
      dy = 0; 
      for (var i=0; i<trial.prompt.length; i++){
        svg.append("text").attr("x", text_start_x).attr("y", instructions_text_start_y).attr("dy", ++lineNumber * lineHeight + dy + "em").style("font-size", font_size+"px").style('fill', 'white').text(trial.prompt[i]);
        lineNumber ++ ;}
    }

    /*/ store response
    var response = {
      rt: null,
      key: null
    }; */

    //setup audio stimulus
    var context = jsPsych.pluginAPI.audioContext();
    if(context !== null){
      var source = context.createBufferSource();
      source.buffer = jsPsych.pluginAPI.getAudioBuffer(trial.audio_stimulus);
      source.connect(context.destination);
    } else {
      var audio = jsPsych.pluginAPI.getAudioBuffer(trial.audio_stimulus);
      audio.currentTime = 0;
    }

    // start audio
    if(context !== null){
    startTime = context.currentTime;
    source.start(startTime);
    } else {
      audio.play();
    } 



    // function to end trial when it is time
    var end_trial = function() {

      console.log('end trial initiated')

      //set button_clicked back to false
      trial.button_clicked = false;

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

      // kill keyboard listeners
      if (typeof keyboardListener !== 'undefined') {
        jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener);
      }

      // stop the audio file if it is playing
      // remove end event listeners if they exist
      if(context !== null){
        source.stop();
        source.onended = function() { }
      } else {
        audio.pause();
        audio.removeEventListener('ended', end_trial);
      }

      // gather the data to store for the trial
      //var trial_data = {
       // "rt": response.rt
      //}; 

      // clear the display
      display_element.innerHTML = '';

      // move on to the next trial
      jsPsych.finishTrial();
    };


// function to handle responses by the subject
var after_response = function() {

  // only record the first response
  //if (response.key == null) {
  //  response = info;
  //}
      if(trial.button_clicked == true){
          end_trial();
        };
      };

// start the response listener
if (trial.choices != jsPsych.NO_KEYS) {
  var keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
    callback_function: after_response,
    valid_responses: trial.choices,
    rt_method: 'performance',
    persist: true,
    allow_held_key: false,
    audio_context: context,
    audio_context_start_time: startTime
  });
} 




 };

  return plugin;
})();
