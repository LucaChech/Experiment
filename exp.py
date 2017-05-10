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

# DEFINING BLOCKS
low_present_normal = []
low_present_critical = []
low_absent_normal = []
low_absent_critical = []
high_present_normal = []
high_present_critical = []
high_absent_normal = []
high_absent_critical = []

list_dict = {}
list_dict['low_present_normal'] = low_present_normal
list_dict['low_present_critical'] = low_present_critical
list_dict['low_absent_normal'] = low_absent_normal
list_dict['low_absent_critical'] = low_absent_critical
list_dict['high_present_normal'] = high_present_normal
list_dict['high_present_critical'] = high_present_critical
list_dict['high_absent_normal'] = high_absent_normal
list_dict['high_absent_critical'] = high_absent_critical

def block(load,present_absent, normal_critical,target_list_name):
    target_list = list_dict[target_list_name]
    for each in my_dict:
        if load in my_dict[each] and present_absent in my_dict[each] and normal_critical in my_dict[each]:
            target_list.append(each)

block('low','Target Present','Normal','low_present_normal')  
block('low','Target Absent','Normal','low_absent_normal')
block('low','Target Present','Critical','low_present_critical')  
block('low','Target Absent','Critical','low_absent_critical')
block('high','Target Present','Normal','high_present_normal')
block('high','Target Present','Critical','high_present_critical')
block('high','Target Absent','Normal','high_absent_normal')
block('high','Target Absent','Critical','high_absent_critical')
#print len(low_present_normal), len(low_absent_normal), len(low_present_critical), len(low_absent_critical)
#print len(high_present_normal), len(high_absent_normal), len(high_present_critical), len(high_absent_critical)
#--------------------

low_one = []
low_two = []
high_one = []
high_two= []

low_one = []
low_one.append(np.random.choice(low_present_normal, 50, replace= False))
low_one.append(np.random.choice(low_present_critical, 10, replace= False))
low_one.append(np.random.choice(low_absent_normal, 50, replace= False))
low_one.append(np.random.choice(low_absent_critical, 10, replace= False))
for each in low_one:
    each = each.tolist()
low_one = [item for sublist in low_one for item in sublist]
print 'low_one',len(low_one),type(low_one)

def complementary_low(list_name):
    for each in list_name:
        if each not in low_one:
            low_two.append(each)
complementary_low(low_present_normal)
print len(low_two)
complementary_low(low_present_critical)
print len(low_two)
complementary_low(low_absent_normal)
print len(low_two)
complementary_low(low_absent_critical)
print len(low_two)
#print block_two
print 'low_two: ', len(low_two), type(low_two)

high_one = []
high_one.append(np.random.choice(high_present_normal, 50, replace= False))
high_one.append(np.random.choice(high_present_critical, 10, replace= False))
high_one.append(np.random.choice(high_absent_normal, 50, replace= False))
high_one.append(np.random.choice(high_absent_critical, 10, replace= False))
for each in high_one:
    each = each.tolist()
high_one = [item for sublist in high_one for item in sublist]
print 'high_one: ',len(high_one),type(high_one)

def complementary_high(list_name):
    for each in list_name:
        if each not in high_one:
            high_two.append(each)
complementary_high(high_present_normal)
print len(high_two)
complementary_high(high_present_critical)
print len(high_two)
complementary_high(high_absent_normal)
print len(high_two)
complementary_high(high_absent_critical)
print len(high_two)
#print block_two
print 'high_two: ', len(high_two), type(high_two)


### RANDOMIZING IMAGE SEQUENCE FOR EACH BLOCK
random.shuffle(low_one)
random.shuffle(low_two)
random.shuffle(high_one)
random.shuffle(high_two)

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
tone1 = sound.Sound('C:/Users/luca.chech.16/Desktop/final/tonesUpdated2/Luca/tones/Subject 666/Tone 1.wav', secs=0.05)
tone2 = sound.Sound('C:/Users/luca.chech.16/Desktop/final/tonesUpdated2/Luca/tones/Subject 666/Tone 2.wav', secs=0.05)
tone3 = sound.Sound('C:/Users/luca.chech.16/Desktop/final/tonesUpdated2/Luca/tones/Subject 666/Tone 3.wav', secs=0.05)
tone4 = sound.Sound('C:/Users/luca.chech.16/Desktop/final/tonesUpdated2/Luca/tones/Subject 666/Tone 4.wav', secs=0.05)

sound_onset = [0.050] * 4 + [0.100] * 4 + [0.150] * 4 + [0.200] * 4 + [0.250] * 4
sound_Hz = ['tone1'] * 5 + ['tone2'] * 5 + ['tone3'] * 5 + ['tone4'] * 5
random.shuffle(sound_onset)
random.shuffle(sound_Hz)
onset_counter = 0
hz_counter = 0

stimulus = 0
print sound_onset, sound_Hz
def handle_trial(play, block_name):
     global i
     global stimulus
     global sound_onset
     global sound_Hz
     global onset_counter
     global hz_counter
     block = block_dict[block_name]
     cross.draw() 
     win.flip()
     core.wait(1) ###Fixation Cross
     image = visual.ImageStim(win=win, image= mypath + block[stimulus])
     image.draw()
     win.flip()
     if play:
        core.wait(sound_onset[onset_counter])
        which_sound = sound_Hz[hz_counter]
        if which_sound == 'tone1':
            tone1.play()
        elif which_sound == 'tone2':
            tone2.play()
        elif which_sound == 'tone3':
            tone3.play()
        elif which_sound == 'tone4':
            tone4.play()
     stopwatch.reset()
     core.wait(1, hogCPUperiod=1)
     lista = event.getKeys(keyList=['space'], timeStamped=stopwatch)
     #print lista
     my_dict[block[stimulus]].append(lista)
     name=my_dict[block[stimulus]][-4]
     #print name
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
     #print keys
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
        
     my_dict[block[stimulus]].append(keys)
     my_dict[block[stimulus]].append(rt_space)

     i = i + 1
     my_dict[block[stimulus]].append(i)
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

block_dict = {}
block_dict['high_one'] = high_one
block_dict['high_two'] = high_two
block_dict['low_one'] = low_one
block_dict['low_two'] = low_two
def block_handler(block_name):
    global stimulus
    global onset_counter
    global hz_counter
    block = block_dict[block_name]
    for stimulus in range(10):
        if i==10 or i==20 or i==30:
            response_keys.draw()
            win.flip()
            event.waitKeys()
        stopwatch = core.Clock()
        event.clearEvents()
        if 'Target Present' in my_dict[block[stimulus]] and 'Critical' in my_dict[block[stimulus]]:
           handle_trial(True, block_name)
           onset_counter = onset_counter + 1
           hz_counter = hz_counter + 1
           print sound_onset[onset_counter], sound_Hz[hz_counter]
        elif 'Target Present' in my_dict[block[stimulus]] and 'Normal' in my_dict[block[stimulus]]:
           handle_trial(False, block_name)
        elif 'Target Absent' in my_dict[block[stimulus]] and 'Critical' in my_dict[block[stimulus]]:
           handle_trial(True, block_name)
           onset_counter = onset_counter + 1
           hz_counter = hz_counter + 1
           print sound_onset[onset_counter], sound_Hz[hz_counter]
        elif 'Target Absent' in my_dict[block[stimulus]] and 'Normal' in my_dict[block[stimulus]]:
           handle_trial(False, block_name)
        print my_dict[block[stimulus]]
block_handler('low_one')
block_handler('high_one')
block_handler('high_two')
block_handler('low_two')




end_of_exp.draw()
win.flip()
event.waitKeys()


### SAVING .CSV
df = pd.DataFrame(my_dict) 
df = df.T
df.reset_index(inplace=True)
df.columns = ['Image Name','Cat. 1', 'Cat. 2','Cat. 3','Cat. 4','Cat. 5','True Skill Rating', 'Load','To be asked', 'Trial Type','Audio','RT to TO', 'RT VS', 'RT to TO','Trial N.']

df.to_csv('Participant_'+expInfo['participant']+'Session_'+expInfo['session']+'.csv')

