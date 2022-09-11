#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Aug  7 21:11:02 2022

@author: jiachengyin
"""

import numpy as np
from matplotlib import pyplot as plt
import random



def f_x(points, data):
    sum = 0
    for i in range(9):
        for j in range(9):
            sum += (np.linalg.norm(points[i, :] - points[j, :]) - data[i][j])**2
    return sum

def f_prime(num, points, data):
    sum = np.zeros(2)
    for i in range(9):
        if i != num:
            sum += 4*(1-data[num, i]/np.linalg.norm(points[i, :] - points[num, :]))*(points[num, :]- points[i, :])
    return sum

def updating_once(points, points_to_be, data):
    for i in range(9):
        points[i, :] = points_to_be[i, :]
        points_to_be[i, :] = points[i, :] - eta*f_prime(i, points, data)

'''
while abs(f_x(x_bar) - f_x(x)) > 10**(-10):
    x = x_bar
    x_bar = x-eta*f_prime(x)
    '''
if __name__ == "__main__": 
    
    data = np.array([[ 0,  206,  429, 1504,  963, 2976, 3095, 2979, 1949],
                  [ 206,    0,  233, 1308,  802, 2815, 2934, 2786, 1771],
                  [ 429,  233,    0, 1075,  671, 2684, 2799, 2631, 1616],
                  [ 1504, 1308, 1075,    0, 1329, 3273, 3053, 2687, 2037],
                  [ 963,  802,  671, 1329,    0, 2013, 2142, 2054,  996],
                  [2976, 2815, 2684, 3273, 2013,    0,  808, 1131, 1307],
                  [3095, 2934, 2799, 3053, 2142,  808,    0,  379, 1235],
                  [2979, 2786, 2631, 2687, 2054, 1131,  379,    0, 1059],
                  [1949, 1771, 1616, 2037,  996, 1307, 1235, 1059,    0]])


    locations = np.zeros((9, 2))
    for i in range(9):
        for j in range(2):
            locations[i][j] = random.randrange(-10**3, 10**3, 1)
    eta = 0.01
    locations_to_be = np.zeros((9, 2))
    for i in range(9):
        locations_to_be[i, :] = locations[i, :] - eta*f_prime(i, locations, data)
    
    while abs(f_x(locations_to_be, data) - f_x(locations, data)) > 0.1:
        updating_once(locations, locations_to_be, data)
    
    print(locations)
    
    
    cities = ['BOS', 'NYC', 'DC', 'MIA', 'CHI','SEA','SF','LA','DEN']
    x = []
    y = []
    for i in range(9):
        x.append(locations[i][0])
        y.append(locations[i][1])

    fig, ax = plt.subplots()
    ax.scatter(x, y)

    for i, txt in enumerate(cities):
        ax.annotate(txt, (x[i], y[i]))
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    