1. We need the example input files here.

This is the forecasting algorithm for Vanderpol Oscillator.

To run it, open Driver_AdaptiveMC.m in Matlab and run.


Suggestions:
Move common code in a folder name algo (Driver_Adaptivemc.m, particle generator, etc)
Move files specific to VDPO into vdpo.
Another folder for generating the output.
Add a test folder with sample input files.

Refactor adaptivemc driver to use the parameters from json input file.


Add a test folder
vdpo_demo.m - Use a sample json file as input, run the Adaptive MC algo on it and produce the prediction charts.
extension 1 - Can a new json file be used as a parameter to the test?

demo: If needed for the demo that we are targetting.


