/**
 * jspsych-two-step-fixation
 *
 **/


jsPsych.plugins["two-step-fixation"] = (function() {

  var plugin = {};

  plugin.info = {
    name: 'two-step-fixation',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Stimulus',
        default: undefined,
        description: 'The HTML string to be displayed'
      },
      text: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Text',
        default: null,
        description: 'Any content here will be displayed on the background.'
      },
      trial_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Trial duration',
        default: null,
        description: 'How long to show trial before it ends.'
      },

    }
  }

  plugin.trial = function(display_element, trial) {
    
    // display stimulus
    new_html='<div id="container" class="exp-container"></div>';
    display_element.innerHTML = new_html;
  
    var svg = d3.select("div#container")
      .append("svg")
      .attr("preserveAspectRatio", "xMinYMin meet")
      .attr("viewBox", "0 0 " + width + " " + height)
      .classed("svg-content", true);


    if (trial.stimulus !== null){
    var main_image = svg.append("svg:image")
        .attr('width', width)
        .attr('height', height)
        .attr("xlink:href", trial.stimulus)
      }



       // add text
       if (trial.text !== null){
        svg.append("text").attr("x", x_center-3).attr("y", y_center).attr("dy", + "em").style("font-size", font_size+"px").style('fill', 'white').text(trial.text);
       }



  
    // draw
   // display_element.innerHTML = new_html;


    // function to end trial when it is time
    var end_trial = function() {

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

      // gather the data to store for the trial
      var trial_data = {
        "stimulus": trial.stimulus,
        "trial_stage": 'fixation'
      };

      // clear the display
      display_element.innerHTML = '';

      // move on to the next trial
      jsPsych.finishTrial(trial_data);
    };



    // end trial if trial_duration is set
    if (trial.trial_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        end_trial();
      }, trial.trial_duration);
    }

  };

  return plugin;
})();
