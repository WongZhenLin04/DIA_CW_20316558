# DIA CW 20316558

This is a documentation on how to set up and run the Godot environment. The only supported OS currently is Windows.

## Set-up (without the Godot Engine)

Make sure that Python is installed on the machine with the pip installer. Use the following to install the necessary libraries:

`pip install godot-rl`

Download the source code and extract the files, then open up a **new terminal** and then direct the directory path to the main directory of the source code.

To run the preset environments:

`python stable_baselines3_exe.py --env_path=executables\default.exe`

The default environment is of medium size and with no ranged attacks, for customisation, you can replace "default" with the following:

|                    |Small     |Medium     |Large     |
|:-------------------|:---------|:----------|:---------|
|With Ranged Attack  |smallBow  |mediumBow  |largeBow  |
|No Ranged Attack    |small     |default    |large     |

To visualise the training with the video game running:

`python stable_baselines3_exe.py --env_path=executables\default.exe --viz`

To speed up the experiments:

`python stable_baselines3_exe.py --env_path=executables\default.exe --speeup=8`

To run the experiment in parallel:

`python stable_baselines3_exe.py --env_path=executables\default.exe --n_parallel=4`

## Set-up (with the Godot Engine)

Download and Setup with Gdot [here]{https://godotengine.org/download/windows/} and import the extracted source code by using import and clicking on the .godot file as seen here:

![](https://i.imgur.com/AGoMWxn.png)

To edit environment variables, open up `Elements\world.tcsn` and click on the `player` node.

To edit agent variables, open up `Elements\knightPlayer.tcsn` and click on the `player` node.

Editing should be done in the inspector on the right panel and looks like this:

![](https://i.imgur.com/aq5mUpj.png)

To export into an executable click `Project > Export` Install windows compiler and click `Export Project`. To run the executable just direct `env_path` to the executable.


