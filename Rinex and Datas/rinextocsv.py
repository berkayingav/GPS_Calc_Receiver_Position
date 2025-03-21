# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import georinex as gr 

obs = gr.load("cags0780.25o")
nav = gr.load("cags0780.25n")


dfObs = obs.to_dataframe()
dfNav = nav.to_dataframe()


dfObs.to_csv('obs_data_.csv')
dfNav.to_csv('nav_data_.csv')
