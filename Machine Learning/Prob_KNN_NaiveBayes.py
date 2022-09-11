#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 22 00:24:37 2022

@author: jiachengyin
"""

import numpy as np
from matplotlib import pyplot as plt
import scipy.io as sio
import scipy.stats as stats
from scipy.spatial import distance
from sklearn.model_selection import train_test_split




class Naive_Classifier:
    def __init__(self, training_X, training_Y):
        self.training_X = training_X
        self.training_Y = training_Y
    def fit(self):
        self.prior = np.zeros(2)
        for i in range(2):
            self.prior[i] = np.count_nonzero(self.training_Y == i)/self.training_X.shape[0]
    def predict(self, testing_X):
        self.testing_X = testing_X.reshape((testing_X.shape[0],1))
        max_class = 0
        max_prob = 0
        for i in range(2):
            x_i = self.training_X[np.where(self.training_Y == i)[0],:]
            product = self.prior[i]
            for j in range(x_i.shape[1]):
                product = product * ((np.count_nonzero(x_i[:, j] == self.testing_X[j,:])+1)/x_i.shape[0])
            if product > max_prob:
                max_prob = product
                max_class = i 
        return max_class
    
### This is the Probability Classifier
class Probability_Classifier:
    def __init__(self, training_X, training_Y):
        self.training_X = training_X
        self.training_Y = training_Y
    def fit(self):
        ## Select for top "kept_axis" number of features with top variances
        self.numfeatures = self.training_X.shape[1]
        ## find the mean vector and the covariance matrix
        self.mean = []
        self.covariance = []
        for i in range(2):
            x_i = self.training_X[np.where(self.training_Y == i)[0],:]
            mean = np.mean(x_i, axis = 0)
            mean = mean.reshape((mean.shape[0],1))
            self.mean.append(mean)
            self.covariance.append(np.cov(x_i, rowvar = False))
        
        self.prior = np.zeros(2)
        for i in range(2):
            self.prior[i] = np.count_nonzero(self.training_Y == i)/self.training_X.shape[0]
        

    def predict(self, X):
        X = X.reshape((X.shape[0],1))
        #print(X)
        #print(self.top_axis_index)
        maximum = 0
        maximum_y = 0
        #print('hello')
        for i in range(2):
            #print(self.covariance[i].shape)
            #print(self.mean.shape)
            #print(X.shape)
            #print(np.linalg.det(self.covariance[i]))
            #prob = 1/np.sqrt(((2*np.pi)**(self.numfeatures))*sci.linalg.det(self.covariance[i]))* \
            #np.exp(-0.5*np.matmul(np.matmul(np.transpose(X-self.mean[i]), \
             #                               np.linalg.inv(self.covariance[i])), \
              #                   (X-self.mean[i])))*self.prior[i]
            #print(self.mean[i].shape, X.shape)
            prob = stats.multivariate_normal.pdf(X.reshape(self.numfeatures), \
            mean= self.mean[i].reshape(self.numfeatures), cov= self.covariance[i]+ np.identity(self.numfeatures)*0.1) * self.prior[i]
            
            if prob > maximum:
                maximum = prob
                #print('hi')
                #print(i)
                maximum_y = i
        #print(maximum_y)
        return maximum_y




### This is the KNN Classifier
def euclidean_distances(X, Y):
    return distance.cdist(X, Y, metric = 'euclidean')

def manhattan_distance(X,Y):
    return distance.cdist(X, Y, metric = 'cityblock')

def chebychev_distance(X,Y):
    return distance.cdist(X, Y, metric = 'chebychev')

class KNearestNeighbor():
    def __init__(self, n_neighbors, distance_measure='L2'):
        self.n_neighbors = n_neighbors
        self.dist = distance_measure
        self.features = None
        self.targets = None
        self.n_samples = None
        self.n_features = None

    def fit(self, features, targets):
        self.features = features
        self.targets = targets
        self.n_samples, self.n_features = features.shape
        

    def predict(self, pred_features):
        #features = pred_features.reshape((pred_features.shape[0],1))
        #print(X)
        #print(self.top_axis_index)
        features = pred_features
        
        
        if self.dist == "L2":
            distance_matrix = euclidean_distances(features, self.features)
        elif self.dist == "L1":
            distance_matrix = manhattan_distance(features, self.features)
        else:
            distance_matrix = chebychev_distance(features, self.features)
        #elif self.dist == "manhattan":
        #    measure = manhattan_distances
        #elif self.dist == "cosine":
        #    measure = cosine_distances
        
        output = np.zeros((features.shape[0], 1))
        
        
        sorted_index_matrix = np.argsort(distance_matrix)
        top_k_index_matrix = sorted_index_matrix[:,:self.n_neighbors]
        for i in range(top_k_index_matrix.shape[0]):
            top_k_targets = self.targets[top_k_index_matrix[i]].astype('int')
            #print(type(top_k_targets[:]))
            #print(np.bincount(top_k_targets[:]))
            top_k_targets = np.delete(top_k_targets, np.where(top_k_targets < 0))
            label = np.bincount(top_k_targets[:]).argmax()
            output[i][0] = label
        return output      
    
if __name__ == "__main__":
    total_data = np.genfromtxt('compas_dataset/propublicaTrain.csv', delimiter=',').astype('double')
    '''total_data = total_data[1:, :]
    training_X = np.delete(total_data, [0, 3], axis = 1)
    training_Y = total_data[:, 0]
    training_race = total_data[:, 3] '''
    
    total_test = np.genfromtxt('compas_dataset/propublicaTest.csv', delimiter=',').astype('double')
    '''total_test = total_test[1:, :]
    testing_X = np.delete(total_test, [0, 3], axis = 1)
    testing_Y = total_test[:, 0]
    testing_race = total_test[:, 3]'''
    final_data = np.concatenate((total_data, total_test), axis = 0)
    X_data = np.delete(total_data, [0], axis = 1)
    Y_data = training_Y = total_data[:, 0]
    
    tra_pro = []
    mle_acc = []
    fivenn_l2 = []
    fivenn_l1 = []
    fivenn_linf = []
    tennn_l1 = []
    tennn_l2 = []
    tennn_linf = []
    naive_bayes = []
    for i in range(9):
        tra_pro.append(0.1*i + 0.1)
        training_X, testing_X, training_Y, testing_Y = train_test_split(X_data, Y_data, test_size=1-(0.1*i + 0.1))
        training_race = training_X[:, 3]
        testing_race = testing_X[:, 3]
        training_X = np.delete(training_X, [3], axis = 1)
        testing_X = np.delete(testing_X, [3], axis = 1)
        
        classifier1 = Probability_Classifier(training_X, training_Y)
        classifier1.fit()
        output_1 = np.zeros(testing_X.shape[0])
        for i in range(output_1.shape[0]):
            #print(classifier.predict(X_test[i, :]))
            output_1[i] = classifier1.predict(testing_X[i, :])
        #output_1 = output_1.reshape(output_1.shape[0], 1)
        mle_acc.append(np.sum(output_1 == testing_Y)/output_1.shape[0])
        
        classifier2 = KNearestNeighbor(5, 'L1')
        classifier2.fit(training_X, training_Y)
        output_2 = classifier2.predict(testing_X)
        output_2 = output_2.reshape(output_2.shape[0])
        fivenn_l1.append(np.sum(output_2 == testing_Y)/output_2.shape[0])
        
        classifier3 = KNearestNeighbor(5, 'L2')
        classifier3.fit(training_X, training_Y)
        output_3 = classifier3.predict(testing_X)
        output_3 = output_3.reshape(output_3.shape[0])
        fivenn_l2.append(np.sum(output_3 == testing_Y)/output_3.shape[0])
        
        classifier4 = KNearestNeighbor(5, 'L_inf')
        classifier4.fit(training_X, training_Y)
        output_4 = classifier4.predict(testing_X)
        output_4 = output_4.reshape(output_4.shape[0])
        fivenn_linf.append(np.sum(output_4 == testing_Y)/output_4.shape[0])
        
        classifier5 = KNearestNeighbor(10, 'L1')
        classifier5.fit(training_X, training_Y)
        output_5 = classifier5.predict(testing_X)
        output_5 = output_5.reshape(output_5.shape[0])
        tennn_l1.append(np.sum(output_5 == testing_Y)/output_5.shape[0])
        
        classifier6 = KNearestNeighbor(10, 'L2')
        classifier6.fit(training_X, training_Y)
        output_6 = classifier6.predict(testing_X)
        output_6 = output_6.reshape(output_6.shape[0])
        tennn_l2.append(np.sum(output_6 == testing_Y)/output_6.shape[0])
        
        classifier7 = KNearestNeighbor(10, 'L_inf')
        classifier7.fit(training_X, training_Y)
        output_7 = classifier7.predict(testing_X)
        output_7 = output_7.reshape(output_7.shape[0])
        tennn_linf.append(np.sum(output_7 == testing_Y)/output_7.shape[0])
    
        classifier8 = Naive_Classifier(training_X, training_Y)
        classifier8.fit()
        output_8 = np.zeros((testing_X.shape[0]))
        for i in range(output_8.shape[0]):
            output_8[i] = classifier8.predict(testing_X[i, :])
        naive_bayes.append(np.sum(output_8 == testing_Y)/output_8.shape[0])
    
    from matplotlib import pyplot as plt
    plt.plot(tra_pro, mle_acc, label = "MLE")
    '''plt.plot(tra_pro, fivenn_l1, label = "5NN_L1")
    plt.plot(tra_pro, fivenn_l2, label = "5NN_L2")
    plt.plot(tra_pro, fivenn_linf, label = "5NN_Linf")'''
    plt.plot(tra_pro, tennn_l1, label = "10NN_L1")
    plt.plot(tra_pro, tennn_l2, label = "10NN_L2")
    plt.plot(tra_pro, tennn_linf, label = "10NN_Linf")
    plt.plot(tra_pro, naive_bayes, label = "naive_bayes")
    plt.legend()
    plt.title("Three classifier class accuracy under different training data proportion")
    plt.xlabel("Training data proportion")
    plt.ylabel("Accuracy")
    plt.yticks(np.arange(0.55, 0.75, 0.05))
    plt.show()
    
    from matplotlib import pyplot as plt
    plt.plot(tra_pro, mle_acc, label = "MLE")
    plt.plot(tra_pro, fivenn_l1, label = "5NN_L1")
    plt.plot(tra_pro, fivenn_l2, label = "5NN_L2")
    plt.plot(tra_pro, fivenn_linf, label = "5NN_Linf")
    '''
    plt.plot(tra_pro, tennn_l1, label = "10NN_L1")
    plt.plot(tra_pro, tennn_l2, label = "10NN_L2")
    plt.plot(tra_pro, tennn_linf, label = "10NN_Linf")'''
    plt.plot(tra_pro, naive_bayes, label = "naive_bayes")
    plt.legend()
    plt.title("Three classifier class accuracy under different training data proportion")
    plt.xlabel("Training data proportion")
    plt.ylabel("Accuracy")
    plt.yticks(np.arange(0.55, 0.75, 0.05))
    plt.show()
    
    
    
    ###### fairness measure:
    training_X, testing_X, training_Y, testing_Y = train_test_split(X_data, Y_data, test_size=0.2)
    training_race = training_X[:, 3]
    testing_race = testing_X[:, 3]
    training_X = np.delete(training_X, [3], axis = 1)
    testing_X = np.delete(testing_X, [3], axis = 1)
    
    classifier1 = Probability_Classifier(training_X, training_Y)
    classifier1.fit()
    output_1 = np.zeros(testing_X.shape[0])
    for i in range(output_1.shape[0]):
        #print(classifier.predict(X_test[i, :]))
        output_1[i] = classifier1.predict(testing_X[i, :])
    
    classifier2 = KNearestNeighbor(5, 'L1')
    classifier2.fit(training_X, training_Y)
    output_2 = classifier2.predict(testing_X)
    output_2 = output_2.reshape(output_2.shape[0])
    
    
    classifier3 = KNearestNeighbor(5, 'L2')
    classifier3.fit(training_X, training_Y)
    output_3 = classifier3.predict(testing_X)
    output_3 = output_3.reshape(output_3.shape[0])
    
    
    classifier4 = KNearestNeighbor(5, 'L_inf')
    classifier4.fit(training_X, training_Y)
    output_4 = classifier4.predict(testing_X)
    output_4 = output_4.reshape(output_4.shape[0])
    
    classifier5 = KNearestNeighbor(10, 'L1')
    classifier5.fit(training_X, training_Y)
    output_5 = classifier5.predict(testing_X)
    output_5 = output_5.reshape(output_5.shape[0])
    
    classifier6 = KNearestNeighbor(10, 'L2')
    classifier6.fit(training_X, training_Y)
    output_6 = classifier6.predict(testing_X)
    output_6 = output_6.reshape(output_6.shape[0])
    
    classifier7 = KNearestNeighbor(10, 'L_inf')
    classifier7.fit(training_X, training_Y)
    output_7 = classifier7.predict(testing_X)
    output_7 = output_7.reshape(output_7.shape[0])

    classifier8 = Naive_Classifier(training_X, training_Y)
    classifier8.fit()
    output_8 = np.zeros((testing_X.shape[0]))
    for i in range(output_8.shape[0]):
        output_8[i] = classifier8.predict(testing_X[i, :])

    ### demographic_parity:
    mle_d_r0p1 = np.count_nonzero(output_1[np.where(testing_race == 0)] == 1)/np.where(testing_race == 0)[0].shape[0]
    mle_d_r1p1 = np.count_nonzero(output_1[np.where(testing_race == 1)] == 1)/np.where(testing_race == 1)[0].shape[0]
    
    fivennl1_d_r0p1 = np.count_nonzero(output_2[np.where(testing_race == 0)] == 1)/np.where(testing_race == 0)[0].shape[0]
    fivennl1_d_r1p1 = np.count_nonzero(output_2[np.where(testing_race == 1)] == 1)/np.where(testing_race == 1)[0].shape[0]
    
    fivennl2_d_r0p1 = np.count_nonzero(output_3[np.where(testing_race == 0)] == 1)/np.where(testing_race == 0)[0].shape[0]
    fivennl2_d_r1p1 = np.count_nonzero(output_3[np.where(testing_race == 1)] == 1)/np.where(testing_race == 1)[0].shape[0]
    
    fivennlinf_d_r0p1 = np.count_nonzero(output_4[np.where(testing_race == 0)] == 1)/np.where(testing_race == 0)[0].shape[0]
    fivennlinf_d_r1p1 = np.count_nonzero(output_4[np.where(testing_race == 1)] == 1)/np.where(testing_race == 1)[0].shape[0]
    
    tennnl1_d_r0p1 = np.count_nonzero(output_5[np.where(testing_race == 0)] == 1)/np.where(testing_race == 0)[0].shape[0]
    tennnl1_d_r1p1 = np.count_nonzero(output_5[np.where(testing_race == 1)] == 1)/np.where(testing_race == 1)[0].shape[0]
    
    tennnl2_d_r0p1 = np.count_nonzero(output_6[np.where(testing_race == 0)] == 1)/np.where(testing_race == 0)[0].shape[0]
    tennnl2_d_r1p1 = np.count_nonzero(output_6[np.where(testing_race == 1)] == 1)/np.where(testing_race == 1)[0].shape[0]
    
    tennnlinf_d_r0p1 = np.count_nonzero(output_7[np.where(testing_race == 0)] == 1)/np.where(testing_race == 0)[0].shape[0]
    tennnlinf_d_r1p1 = np.count_nonzero(output_7[np.where(testing_race == 1)] == 1)/np.where(testing_race == 1)[0].shape[0]
    
    naive_d_r0p1 = np.count_nonzero(output_8[np.where(testing_race == 0)] == 1)/np.where(testing_race == 0)[0].shape[0]
    naive_d_r1p1 = np.count_nonzero(output_8[np.where(testing_race == 1)] == 1)/np.where(testing_race == 1)[0].shape[0]
    
    #difference between two races
    mle_pos = abs(mle_d_r0p1- mle_d_r1p1)
    
    fivennl1_pos = abs(fivennl1_d_r0p1- fivennl1_d_r1p1)
    fivennl2_pos = abs(fivennl2_d_r0p1- fivennl2_d_r1p1)
    fivennlinf_pos = abs(fivennlinf_d_r0p1- fivennlinf_d_r1p1)
    
    tennnl1_pos = abs(tennnl1_d_r0p1- tennnl1_d_r1p1)
    tennnl2_pos = abs(tennnl2_d_r0p1- tennnl2_d_r1p1)
    tennnlinf_pos = abs(tennnlinf_d_r0p1- tennnlinf_d_r1p1)
    
    naive_pos = abs(naive_d_r0p1- naive_d_r1p1)
    
    
    ### Equalized Odds:
    # true positive
    mle_e_r0y1p1 = np.count_nonzero(output_1[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1)).shape[0]
    mle_e_r1y1p1 = np.count_nonzero(output_1[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1)).shape[0]
    
    fivennl1_e_r0y1p1 = np.count_nonzero(output_2[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1)).shape[0]
    fivennl1_e_r1y1p1 = np.count_nonzero(output_2[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1)).shape[0]
    
    fivennl2_e_r0y1p1 = np.count_nonzero(output_3[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1)).shape[0]
    fivennl2_e_r1y1p1 = np.count_nonzero(output_3[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1)).shape[0]
    
    fivennlinf_e_r0y1p1 = np.count_nonzero(output_4[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1)).shape[0]
    fivennlinf_e_r1y1p1 = np.count_nonzero(output_4[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1)).shape[0]
    
    tennnl1_e_r0y1p1 = np.count_nonzero(output_5[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1)).shape[0]
    tennnl1_e_r1y1p1 = np.count_nonzero(output_5[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1)).shape[0]
    
    tennnl2_e_r0y1p1 = np.count_nonzero(output_6[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1)).shape[0]
    tennnl2_e_r1y1p1 = np.count_nonzero(output_6[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1)).shape[0]
    
    tennnlinf_e_r0y1p1 = np.count_nonzero(output_7[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1)).shape[0]
    tennnlinf_e_r1y1p1 = np.count_nonzero(output_7[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1)).shape[0]
    
    naive_e_r0y1p1 = np.count_nonzero(output_8[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 1)).shape[0]
    naive_e_r1y1p1 = np.count_nonzero(output_8[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 1)).shape[0]
    
    
    mle_e_tp = abs(mle_e_r0y1p1- mle_e_r1y1p1)
    
    fivennl1_e_tp = abs(fivennl1_e_r0y1p1- fivennl1_e_r1y1p1)
    fivennl2_e_tp = abs(fivennl2_e_r0y1p1- fivennl2_e_r1y1p1)
    fivennlinf_e_tp = abs(fivennlinf_e_r0y1p1- fivennlinf_e_r1y1p1)
    
    tennnl1_e_tp = abs(tennnl1_e_r0y1p1- tennnl1_e_r1y1p1)
    tennnl2_e_tp = abs(tennnl2_e_r0y1p1- tennnl2_e_r1y1p1)
    tennnlinf_e_tp = abs(tennnlinf_e_r0y1p1- tennnlinf_e_r1y1p1)
    
    naive_e_tp = abs(naive_e_r0y1p1- naive_e_r1y1p1)
    
    # true negative
    mle_e_r0y0p0 = np.count_nonzero(output_1[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0)).shape[0]
    mle_e_r1y0p0 = np.count_nonzero(output_1[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0)).shape[0]
    
    fivennl1_e_r0y0p0 = np.count_nonzero(output_2[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0)).shape[0]
    fivennl1_e_r1y0p0 = np.count_nonzero(output_2[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0)).shape[0]
    
    fivennl2_e_r0y0p0 = np.count_nonzero(output_3[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0)).shape[0]
    fivennl2_e_r1y0p0 = np.count_nonzero(output_3[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0)).shape[0]
    
    fivennlinf_e_r0y0p0 = np.count_nonzero(output_4[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0)).shape[0]
    fivennlinf_e_r1y0p0 = np.count_nonzero(output_4[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0)).shape[0]
    
    tennnl1_e_r0y0p0 = np.count_nonzero(output_5[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0)).shape[0]
    tennnl1_e_r1y0p0 = np.count_nonzero(output_5[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0)).shape[0]
    
    tennnl2_e_r0y0p0 = np.count_nonzero(output_6[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0)).shape[0]
    tennnl2_e_r1y0p0 = np.count_nonzero(output_6[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0)).shape[0]
    
    tennnlinf_e_r0y0p0 = np.count_nonzero(output_7[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0)).shape[0]
    tennnlinf_e_r1y0p0 = np.count_nonzero(output_7[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0)).shape[0]
    
    naive_e_r0y0p0 = np.count_nonzero(output_8[np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(testing_Y == 0)).shape[0]
    naive_e_r1y0p0 = np.count_nonzero(output_8[np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(testing_Y == 0)).shape[0]
    
    
    mle_e_fn = abs(mle_e_r0y0p0- mle_e_r1y0p0)
    
    fivennl1_e_fn = abs(fivennl1_e_r0y0p0- fivennl1_e_r1y0p0)
    fivennl2_e_fn = abs(fivennl2_e_r0y0p0- fivennl2_e_r1y0p0)
    fivennlinf_e_fn = abs(fivennlinf_e_r0y0p0- fivennlinf_e_r1y0p0)
    
    tennnl1_e_fn = abs(tennnl1_e_r0y0p0- tennnl1_e_r1y0p0)
    tennnl2_e_fn = abs(tennnl2_e_r0y0p0- tennnl2_e_r1y0p0)
    tennnlinf_e_fn = abs(tennnlinf_e_r0y0p0- tennnlinf_e_r1y0p0)
    
    naive_e_fn = abs(naive_e_r0y0p0- naive_e_r1y0p0)
    
    
    ### Predictive Disparity
    #Positive Predictive:
    mle_e_r0p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_1 == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(output_1 == 1)).shape[0]
    mle_e_r1p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_1 == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(output_1 == 1)).shape[0]
    
    fivennl1_e_r0p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_2 == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(output_2 == 1)).shape[0]
    fivennl1_e_r1p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_2 == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(output_2 == 1)).shape[0]
    
    fivennl2_e_r0p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_3 == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(output_3 == 1)).shape[0]
    fivennl2_e_r1p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_3 == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(output_3 == 1)).shape[0]
    
    fivennlinf_e_r0p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_4 == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(output_4 == 1)).shape[0]
    fivennlinf_e_r1p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_4 == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(output_4 == 1)).shape[0]
    
    tennnl1_e_r0p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_5 == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(output_5 == 1)).shape[0]
    tennnl1_e_r1p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_5 == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(output_5 == 1)).shape[0]
    
    tennnl2_e_r0p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_6 == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(output_6 == 1)).shape[0]
    tennnl2_e_r1p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_6 == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(output_6 == 1)).shape[0]
    
    tennnlinf_e_r0p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_7 == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(output_7 == 1)).shape[0]
    tennnlinf_e_r1p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_7 == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(output_7 == 1)).shape[0]
    
    naive_e_r0p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_8 == 1))] == 1)/np.intersect1d(np.where(testing_race == 0), np.where(output_8 == 1)).shape[0]
    naive_e_r1p1y1 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_8 == 1))] == 1)/np.intersect1d(np.where(testing_race == 1), np.where(output_8 == 1)).shape[0]
    
    
    mle_e_pp = abs(mle_e_r0p1y1- mle_e_r1p1y1)
    
    fivennl1_e_pp = abs(fivennl1_e_r0p1y1- fivennl1_e_r1p1y1)
    fivennl2_e_pp = abs(fivennl2_e_r0p1y1- fivennl2_e_r1p1y1)
    fivennlinf_e_pp = abs(fivennlinf_e_r0p1y1- fivennlinf_e_r1p1y1)
    
    tennnl1_e_pp = abs(tennnl1_e_r0p1y1- tennnl1_e_r1p1y1)
    tennnl2_e_pp = abs(tennnl2_e_r0p1y1- tennnl2_e_r1p1y1)
    tennnlinf_e_pp = abs(tennnlinf_e_r0p1y1- tennnlinf_e_r1p1y1)
    
    naive_e_pp = abs(naive_e_r0p1y1- naive_e_r1p1y1)
    
    
    #Negative Predictive:
    mle_e_r0p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_1 == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(output_1 == 0)).shape[0]
    mle_e_r1p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_1 == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(output_1 == 0)).shape[0]
    
    fivennl1_e_r0p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_2 == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(output_2 == 0)).shape[0]
    fivennl1_e_r1p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_2 == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(output_2 == 0)).shape[0]
    
    fivennl2_e_r0p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_3 == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(output_3 == 0)).shape[0]
    fivennl2_e_r1p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_3 == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(output_3 == 0)).shape[0]
    
    fivennlinf_e_r0p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_4 == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(output_4 == 0)).shape[0]
    fivennlinf_e_r1p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_4 == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(output_4 == 0)).shape[0]
    
    tennnl1_e_r0p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_5 == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(output_5 == 0)).shape[0]
    tennnl1_e_r1p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_5 == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(output_5 == 0)).shape[0]
    
    tennnl2_e_r0p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_6 == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(output_6 == 0)).shape[0]
    tennnl2_e_r1p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_6 == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(output_6 == 0)).shape[0]
    
    tennnlinf_e_r0p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_7 == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(output_7 == 0)).shape[0]
    tennnlinf_e_r1p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_7 == 0))] == 0)/np.intersect1d(np.where(testing_race == 1), np.where(output_7 == 0)).shape[0]
    
    naive_e_r0p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 0), np.where(output_8 == 0))] == 0)/np.intersect1d(np.where(testing_race == 0), np.where(output_8 == 0)).shape[0]
    naive_e_r1p0y0 = np.count_nonzero(testing_Y[np.intersect1d(np.where(testing_race == 1), np.where(output_8 == 0))] == 0)/(np.intersect1d(np.where(testing_race == 1), np.where(output_8 == 0)).shape[0]+1)
    
    
    mle_e_np = abs(mle_e_r0p0y0- mle_e_r1p0y0)
    
    fivennl1_e_np = abs(fivennl1_e_r0p0y0- fivennl1_e_r1p0y0)
    fivennl2_e_np = abs(fivennl2_e_r0p0y0- fivennl2_e_r1p0y0)
    fivennlinf_e_np = abs(fivennlinf_e_r0p0y0- fivennlinf_e_r1p0y0)
    
    tennnl1_e_np = abs(tennnl1_e_r0p0y0- tennnl1_e_r1p0y0)
    tennnl2_e_np = abs(tennnl2_e_r0p0y0- tennnl2_e_r1p0y0)
    tennnlinf_e_np = abs(tennnlinf_e_r0p0y0- tennnlinf_e_r1p0y0)
    
    naive_e_np = abs(naive_e_r0p0y0- naive_e_r1p0y0)
    
    