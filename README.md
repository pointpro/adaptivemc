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

Steps to Run UI:
Input Layer:
1. Upload "Manage Support Files" ... these are all the files not starting with the name "Input"
2. Hit "Run Model". This will process the input files and generate json outputs for the backend.


Output Layer:
1. After completing the input layer steps, go to the data outputs tab.
2. Upload file named Output_XXX_Main.xlsx. Wait for the upload to compelete (name will disappear from the upload bar)
3. Upload file named Output_XXX_Raw.xlsx. Wait for the upload to complete.
4. Close the upload window. Graphs will automatically appear. 
