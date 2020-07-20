Two important things to know:

* For settings, see two-step-settings.js . They should be descriptively named and you can search for their use, but feel free to ask Val questions if not.
* For this task, we are using the same probability files as in the Matlab version, so we use d3 csv requests, which is why the main javascript and the html are combined


Based on “MBMF_200trials_clweaner” provided by Catherine Hartley
Payoffs created by taking their mat files and doing:
[squeeze(payoff(1,:,:))' squeeze(payoff(2,:,:))']
And adding a header of 0,1,2,3
