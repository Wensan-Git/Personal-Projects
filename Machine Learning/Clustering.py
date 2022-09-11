#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Aug  7 23:19:16 2022

@author: jiachengyin
"""

import numpy as np
from matplotlib import pyplot as plt
import scipy.io as sio
import scipy.stats as stats
from scipy.spatial import distance
import random
import sklearn.datasets


class kMeans:
    def __init__(self, scaling_factor, num_clusters,data):
        self.num_clu = num_clusters
        self.data = data
        self.data_dim = self.data.shape[1]
        self.centers = np.zeros((self.num_clu, self.data_dim))
        for i in range(self.num_clu):
            for j in range(self.data_dim):
                self.centers[i][j] = scaling_factor*random.random()
        self.prev_cost = 1e20
        
    def assign_cluster(self):
        #print('assign')
        distance_matrix = np.zeros((self.data.shape[0], self.num_clu))
        for i in range(self.data.shape[0]):
            for j in range(self.num_clu):
                distance_matrix[i][j] = np.linalg.norm(self.data[i, :]- self.centers[j, :])
        self.assignment = np.argmin(distance_matrix, axis = 1)
    
    def update_center(self):
        #print('update')
        for i in range(self.num_clu):
            mean = np.mean(self.data[np.where(self.assignment == i)], axis = 0)
            #print(self.data[np.where(self.assignment == i)].shape)
            mean.reshape((1, mean.shape[0]))
            self.centers[i] = mean
    
    def training(self):
        self.assign_cluster()
        self.update_center()
        self.curr_cost = 0
        for i in range(self.data.shape[0]):
            self.curr_cost += np.linalg.norm(self.centers[self.assignment[i], :] - self.data[i, :])
        while self.curr_cost != self.prev_cost:
            print('hi')
            self.prev_cost = self.curr_cost
            self.assign_cluster()
            self.update_center()
            
            self.curr_cost = 0
            for i in range(self.data.shape[0]):
                #print('hello')
                self.curr_cost += np.linalg.norm(self.centers[self.assignment[i], :] - self.data[i, :])
                
            #print(self.curr_cost, self.prev_cost)
        return self.centers
    
    def return_assignment(self):
        return self.assignment
    

### Spectral Clustering Part
def r_neighbors(point, data, r):
    point = point.reshape((1, point.shape[0]))
    distance_matrix = distance.cdist(point, data, metric = 'euclidean')
    ranked_index = distance_matrix.argsort()[::1]
    return ranked_index[0][1:r+1]

def L_matrix(data, r):
    print(data.shape)
    W = np.zeros((data.shape[0], data.shape[0]))
    for i in range(data.shape[0]):
        for j in range(data.shape[0]):
            if i in r_neighbors(data[j, :], data, r):
                print(i,j)
                W[i][j] = 1
    for i in range(data.shape[0]):
        i_neighbor = r_neighbors(data[i, :], data, r)
        for element in i_neighbor:
            W[i][element] = 1
    D = np.zeros((data.shape[0], data.shape[0]))
    for i in range(data.shape[0]):
        D[i][i] = np.sum(W[i])
        
    return D - W

def spectral_clustering(L_matrix, r, k):
    evalue, evector = np.linalg.eig(L_matrix)
    index = evalue.argsort()[::1]
    lowest_index = index[0:k]
    evector = evector[:, lowest_index]
    evector = np.real(evector)
    print(evector.shape)
    print(evector)
    clustering = kMeans(0.1, 2, evector)
    centers = clustering.training()
    assign = clustering.return_assignment()
    return evector, centers, assign
    
    
    
    
    
    
    
if __name__ == "__main__":
        
    data, useless = sklearn.datasets.make_circles((500, 100), factor = 0.5)
    
    
    circle = kMeans(1, 2, data)
    centers = circle.training()
    assign = circle.return_assignment()
    
    for i in range(data.shape[0]):
        if assign[i] == 0:
            plt.scatter(data[i, 0],data[i, 1], color = "blue") 
        
        else:
            plt.scatter(data[i, 0],data[i, 1], color = "yellow") 
    
    plt.scatter(centers[0, 0],centers[0, 1], color = "purple")
    plt.scatter(centers[1, 0],centers[1, 1], color = "black") 
    
    #moon dataset 
    moon_data, useless = sklearn.datasets.make_moons(600)
    
    moon = kMeans(1, 2, moon_data)
    moon_centers = moon.training()
    moon_assign = moon.return_assignment()
    
    for i in range(moon_data.shape[0]):
        if moon_assign[i] == 0:
            plt.scatter(moon_data[i, 0],moon_data[i, 1], color = "blue") 
        
        else:
            plt.scatter(moon_data[i, 0],moon_data[i, 1], color = "yellow") 
    
    plt.scatter(moon_centers[0, 0],moon_centers[0, 1], color = "purple")
    plt.scatter(moon_centers[1, 0],moon_centers[1, 1], color = "black") 
    
#line data set
    l1_data = np.zeros((300, 2))
    for i in range(300):
        l1_data[i][1] = random.random()
        l1_data[i][0] += 0.5
    l2_data = np.ones((300, 2))
    for i in range(300):
        l2_data[i][1] = random.random()
        
    l_data =  np.vstack((l1_data,l2_data))
    
    l = kMeans(1, 2, l_data)
    l_centers = l.training()
    l_assign = l.return_assignment()
    
    for i in range(l_data.shape[0]):
        if l_assign[i] == 0:
            plt.scatter(l_data[i, 0],l_data[i, 1], color = "blue") 
        
        else:
            plt.scatter(l_data[i, 0],l_data[i, 1], color = "yellow") 
    
    plt.scatter(l_centers[0, 0],l_centers[0, 1], color = "purple")
    plt.scatter(l_centers[1, 0],l_centers[1, 1], color = "black") 
    #spectral clustering for concentric circle:
    L_mat = L_matrix(data, 10)
    evecs, spec_circle_center, assign_spe_circle = spectral_clustering(L_mat, 10, 2)
    

    for i in range(data.shape[0]):
        if assign_spe_circle[i] == 0:
            plt.scatter(data[i, 0],data[i, 1], color = "blue") 
        
        else:
            plt.scatter(data[i, 0],data[i, 1], color = "yellow") 
            
            
            
    L_mat = L_matrix(data, 1)
    evecs, spec_circle_center, assign_spe_circle = spectral_clustering(L_mat, 1, 2)
    
    for i in range(data.shape[0]):
        if assign_spe_circle[i] == 0:
            plt.scatter(data[i, 0],data[i, 1], color = "blue") 
        
        else:
            plt.scatter(data[i, 0],data[i, 1], color = "yellow") 
    
    L_mat = L_matrix(data, 3)
    evecs, spec_circle_center, assign_spe_circle = spectral_clustering(L_mat, 3, 2)

    
    for i in range(data.shape[0]):
        if assign_spe_circle[i] == 0:
            plt.scatter(data[i, 0],data[i, 1], color = "blue") 
        
        else:
            plt.scatter(data[i, 0],data[i, 1], color = "yellow") 
            
    L_mat = L_matrix(data, 100)
    evecs, spec_circle_center, assign_spe_circle = spectral_clustering(L_mat, 100, 2)
    
    for i in range(data.shape[0]):
        if assign_spe_circle[i] == 0:
            plt.scatter(data[i, 0],data[i, 1], color = "blue") 
        
        else:
            plt.scatter(data[i, 0],data[i, 1], color = "yellow") 
    

    # spectral clustering for moon_shaped data

    L_mat = L_matrix(moon_data, 100)
    evecs, moon_center, assign_moon = spectral_clustering(L_mat, 100, 2)
    
    for i in range(moon_data.shape[0]):
        if assign_moon[i] == 0:
            plt.scatter(moon_data[i, 0],moon_data[i, 1], color = "blue") 
        
        else:
            plt.scatter(moon_data[i, 0],moon_data[i, 1], color = "yellow") 

    L_mat = L_matrix(moon_data, 10)
    evecs, moon_center, assign_moon = spectral_clustering(L_mat, 10, 2)
    
    for i in range(moon_data.shape[0]):
        if assign_moon[i] == 0:
            plt.scatter(moon_data[i, 0],moon_data[i, 1], color = "blue") 
        
        else:
            plt.scatter(moon_data[i, 0],moon_data[i, 1], color = "yellow") 

    
    L_mat = L_matrix(moon_data, 3)
    evecs, moon_center, assign_moon = spectral_clustering(L_mat, 3, 2)
    
    for i in range(moon_data.shape[0]):
        if assign_moon[i] == 0:
            plt.scatter(moon_data[i, 0],moon_data[i, 1], color = "blue") 
        
        else:
            plt.scatter(moon_data[i, 0],moon_data[i, 1], color = "yellow") 

    
    ### spectral clustering for s_shaped data:
    
       
    L_mat = L_matrix(l_data, 10)
    evecs, l_center, assign_l = spectral_clustering(L_mat, 10, 1)
    
    for i in range(l_data.shape[0]):
        if assign_l[i] == 0:
            plt.scatter(l_data[i, 0],l_data[i, 1], color = "blue") 
        
        else:
            plt.scatter(l_data[i, 0],l_data[i, 1], color = "yellow")

    
        
    L_mat = L_matrix(l_data, 5)
    evecs, l_center, assign_l = spectral_clustering(L_mat, 5, 1)
    
    for i in range(l_data.shape[0]):
        if assign_l[i] == 0:
            plt.scatter(l_data[i, 0],l_data[i, 1], color = "blue") 
        
        else:
            plt.scatter(l_data[i, 0],l_data[i, 1], color = "yellow")


       
    L_mat = L_matrix(l_data, 70)
    evecs, l_center, assign_l = spectral_clustering(L_mat, 70, 1)
    
    for i in range(l_data.shape[0]):
        if assign_l[i] == 0:
            plt.scatter(l_data[i, 0],l_data[i, 1], color = "blue") 
        
        else:
            plt.scatter(l_data[i, 0],l_data[i, 1], color = "yellow")

    
    
    
    
    
    
    
    
    
    
    
    
    
    
