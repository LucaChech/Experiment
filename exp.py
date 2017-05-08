#IMPORTING LIBRARIES
from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import visual
from psychopy import prefs
prefs.general['audioLib'] = ['pyo']
from psychopy import locale_setup, core, data, event, logging, sound, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import sys # to get file system encoding
from os import listdir
from os.path import isfile, join
from shutil import copyfile
from random import shuffle
import pandas as pd
import csv
from psychopy.iohub import launchHubServer
import random 
import pyglet
import time
from pdb import set_trace


#RECREATING exp_dict

#df = pd.DataFrame.from_csv('C:/Users/nilli lab/Desktop/Luca Exp/jupyter exp/randomization_short.csv')
df = pd.DataFrame.from_csv('C:/Users/luca.chech.16/Desktop/jupyter exp/randomization.csv')

df.reset_index(drop=False,) #inplace = 'True')
image_names = df.index.tolist()
cat1 = df['Cat.1'].tolist()
cat2 = df['Cat.2'].tolist()
cat3 = df['Cat.3'].tolist()
cat4 = df['Cat.4'].tolist()
cat5 = df['Cat.5'].tolist()
ts = df['TS'].tolist()
load = df['Load'].tolist()
question = df['question'].tolist()
trial_type = df['present_absent'].tolist()
critical = df['trial_type'].tolist()
my_dict ={z[0]:list(z[1:]) for z in zip(image_names,cat1,cat2,cat3,cat4,cat5,ts,load,question,trial_type,critical)}

random.shuffle(image_names)

# Store info about the experiment session
expName = 'participant info'  # from the Builder filename that created this script
expInfo = {u'session': u'001', u'participant': u''}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False: core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName

# CREATING TRIAL OBJECTS

#WINDOW
win = visual.Window(size=(1920, 1080), fullscr=True, screen=0, allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True,
    )
# FIXATION CROSS
cross = visual.TextStim(win, '+', color='black')

# INSTRUCTIONS
Instructions_screen_1 = visual.TextStim(win, 
'                                        INSTRUCTIONS \n'
'\n'
'     You will be presented with a series of briefly displayed images.\n'
'                  Your task is to carefully examine each image.\n'
'  Following each image, you will be asked whether a specific object\n'
'                     (e.g. a chair) was present in the image.\n'
'    Please reply as quickly and accurately as possible by pressing:\n'
'                               Q if the object was present\n'
'                               P if the object was absent\n'
' The experiment is run in short blocks with a break after each block.\n'
'  Please keep your fingers on the Q and P keys throughout a block.'
'\n'
'                             press SPACEBAR to continue'
,
alignHoriz='center',
alignVert='center',
height= 0.10,
wrapWidth=2 )



Instructions_screen_2 = visual.TextStim(win, 
'     Sometimes, the image will be accompanied by a brief sound.\n'
'If you hear a sound, please press SPACEBAR as quickly as possible,\n'
'and only afterwards provide your answer to the image-related question\n'
'                               by pressing either Q or P.\n'
'\n'
'\n'

'                                 Press SPACEBAR to start.'
,
alignHoriz='center',
alignVert='center',
height= 0.10,
wrapWidth=2 )


response_keys = visual.TextStim(win, 
'                                    End of block. \n'
'\n'
' During the next block please use the following response keys: \n'
'\n'
'                         Q if the object was present \n'
'                         P if the object was absent \n'
'                    SPACEBAR when you hear a sound'
'\n'
'\n'
'\n'
'              Press SPACEBAR to begin  the next block.',
alignHoriz='center',
alignVert='center',
height= 0.10,
wrapWidth=2 )


#END OF EXPERIMENT MESSAGE
end_of_exp = visual.TextStim(win, 
'The experiment is over.\n'
'\n'
'\n'
'\n'
'          Thank you.',
height=0.12)

#SOUND
f = sound.Sound('C:/Users/luca.chech.16/Desktop/final/tonesUpdated2/Luca/tones/Subject 666/PureTone_F1025_t100.wav', secs=0.15) 



def handle_trial(play):
     global i
     cross.draw() 
     win.flip()
     core.wait(1) ###Fixation Cross
     image = visual.ImageStim(win=win, image= mypath + image_names[stimulus])
     image.draw()
     win.flip()
     if play:
        core.wait(0.500)
        f.play()
     stopwatch.reset()
     core.wait(1, hogCPUperiod=1)
     lista = event.getKeys(keyList=['space'], timeStamped=stopwatch)
     print lista
     my_dict[image_names[stimulus]].append(lista)
     name=my_dict[image_names[stimulus]][-4]
     if 'pottedplant' in name:
         search_text = visual.TextStim(win, 'Was there a plant ?',
     wrapWidth=2,
     height=0.12)
     elif 'aeroplane' in name:
         search_text = visual.TextStim(win, 'Was there an aeroplane ?',
     wrapWidth=2,
     height=0.12)
     else:
         search_text = visual.TextStim(win, 'Was there a' + name + ' ?',
     wrapWidth=2,
     height=0.12)
     search_text.draw()
     win.flip()
     stopwatch.reset()
     keys = event.waitKeys(keyList=['q','p','space'],timeStamped=stopwatch)
     print keys
     rt_space = -999
     wait = True
     for k in keys:
         if k[0] == 'space':
             rt_space = [k[0],k[1]]
         if k[0] == 'q' or k[0] == 'p':
            wait = False
     
     while wait:
        keys = event.waitKeys(keyList=['q','p'],timeStamped=stopwatch)
        letters = [t[0] for t in keys]
        if ('p' in letters) or ('q' in letters):
            wait = False
        
     my_dict[image_names[stimulus]].append(keys)
     my_dict[image_names[stimulus]].append(rt_space)

     i = i + 1
     my_dict[image_names[stimulus]].append(i)
     stopwatch.reset()


#CONSTANTS
categories = [' bottle', ' horse', ' pottedplant', ' dog', ' cat', ' person', ' aeroplane', ' car', ' chair', ' sofa', ' bird', ' boat']
response = []
reaction_t = []
#mypath = 'C:/Users/nilli lab/Desktop/Luca Exp/jupyter exp/images/'
mypath = 'C:/Users/luca.chech.16/Desktop/jupyter exp/images/'
absent_question = []
stopwatch = core.Clock()
i = 0
Instructions_screen_1.draw()
win.flip()
event.waitKeys(keyList=['space'])
Instructions_screen_2.draw()
win.flip()
event.waitKeys()

for stimulus in range(len(my_dict)):
    if i == 120:
        response_keys.draw()
        win.flip()
        event.waitKeys()
    if i == 240 or i == 360:
        response_keys.draw()
        win.flip()
        event.waitKeys()
    stopwatch = core.Clock()
    event.clearEvents()
    if 'Target Present' in my_dict[image_names[stimulus]] and 'Critical' in my_dict[image_names[stimulus]]:
       handle_trial(True)
       
    elif 'Target Present' in my_dict[image_names[stimulus]] and 'Normal' in my_dict[image_names[stimulus]]:
       handle_trial(False)
        
    elif 'Target Absent' in my_dict[image_names[stimulus]] and 'Critical' in my_dict[image_names[stimulus]]:
       handle_trial(True)
       
    elif 'Target Absent' in my_dict[image_names[stimulus]] and 'Normal' in my_dict[image_names[stimulus]]:
       handle_trial(False)
       
       
end_of_exp.draw()
win.flip()
event.waitKeys()


### SAVING .CSV
df = pd.DataFrame(my_dict) 
df = df.T
df.reset_index(inplace=True)
df.columns = ['Image Name','Cat. 1', 'Cat. 2','Cat. 3','Cat. 4','Cat. 5','True Skill Rating', 'Load','To be asked', 'Trial Type','Audio','RT to TO', 'RT VS', 'RT to TO','Trial N.']

df.to_csv('Participant_'+expInfo['participant']+'Session_'+expInfo['session']+'.csv')

