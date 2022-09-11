import numpy as np
import warnings


class LogisticRegression():
    def __init__(self, learning_rate=1e-1, max_iter=1000):
        """
        A logistic regression classifier. This binary classifier learns a linear
        boundary that separates input space into two, such that points
        on one side of the line are one class and points on the other side are
        the other class.

        Args:
            max_iter (int): the perceptron learning algorithm stops after
            this many iterations if it has not converged.

            learning_rate (float): how large of a step to take at each update

        """
        self.learning_rate = learning_rate
        self.max_iter = max_iter

    def fit(self, X, y):
        """
        Fit the logistic regression to the data. You should not have to modify
        this function -- all your work should go in `update_weights` and
        `predict`.

        Args:
            X (np.ndarray): a NxK array containing N examples each with K features.
            y (np.ndarray): a Nx1 array containing binary targets.
        Returns:
            n_iters: the number of iterations the model took to converge,
                or self.max_iter
        """
        X = self.add_intercept(X)
        self.weights = np.zeros(X.shape[1])

        for n_iters in range(1, 1 + self.max_iter):
            stop = self.update_weights(X, y)
            if stop:
                break

        return n_iters

    def sigmoid(self, x):
        """
        Helper function to compute the sigmoid
        """
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", category=RuntimeWarning)
            return 1 / (1 + np.exp(-x))

    def add_intercept(self, X):
        """
        Helper function to add a column of 1's to your features
        """
        return np.concatenate([np.ones([X.shape[0], 1]), X], axis=1)

    def update_weights(self, X, y):
        """
        Perform one iteration of (batch) gradient descent updates for your
            logistic regression

        Pseudocode:
            predict p(y' | X, weights) for the entire dataset X
            compute gradient as (y_i - p(y' | X_i, weights)) * X_i
                for each example i, then average over all examples
            update the weights by gradient * learning_rate
            return whether logistic regression has converged

        Note: you should return True if the gradient is small. That is,
            if `np.all(np.isclose(gradient, 0))`

        Args:
            X: the Nx(K+1) matrix of features, including an intercept
            y: the Nx1 array of targets (these are {0, 1} labels)

        Returns:
            Boolean indicating whether the model has converged
        """
        X_copy = np.copy(X)
        X_copy = np.matmul(X_copy, self.weights) #input to sigmoid function.
        function = np.vectorize(self.sigmoid)
        probability = function(X_copy) # NX1
        difference = np.subtract(y, probability)
        gradient = X*difference[:, np.newaxis]
        average_gradient = np.mean(gradient, axis=0)
        self.weights = self.weights + self.learning_rate * average_gradient
        return np.all(np.isclose(average_gradient, 0))
        
        
        
        raise NotImplementedError

    def predict(self, X):
        """
        Given features, a 2D numpy array, use the trained model to predict
        target classes. Call this after calling fit.

        Note: Keep the `self.add_intercept` to ensure you include the intercept

        Args:
            X (np.ndarray): 2D array containing real-valued inputs.
        Returns:
            predictions (np.ndarray): Output of trained model on features.
        """
        X = self.add_intercept(X)
        X = np.matmul(X, self.weights)
        function = np.vectorize(self.sigmoid)
        probability = function(X)
        for i in range(X.shape[0]):
            if probability[i] > 0.5:
                probability[i] = 1
            else:
                probability[i] = 0
        return probability
        
        raise NotImplementedError
