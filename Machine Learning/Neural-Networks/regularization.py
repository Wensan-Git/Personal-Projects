import numpy as np


class Regularizer:
    """
    Regularization for FullyConnected layers
    """
    def __init__(self, alpha=0.01, penalty='l2'):
        """
        penalty: type of distance measure, either "l1" or "l2"
        alpha: weight parameter for the regularization gradient
        """
        self.alpha = alpha
        self.penalty = penalty

    def grad(self, weights):
        if self.penalty == "l1":
            return self.l1_grad(weights)
        elif self.penalty == "l2":
            return self.l2_grad(weights)

    def l1_grad(self, weights):
        """
        Compute the *gradient* of L1 regularization
            with respect to the given weights.

        L1 regularization is just the absolute value, so the partial gradient
            for a given weight is either 1, -1, or 0 depending on whether the
            weight is greater than, less than, or equal to 0.

        Note: weights[0, :] contains the intercept, and you should not apply
            regularization to those parameters.
        """
        ret = weights.copy()
        ret[0,:] = 0
        ret[ret>0] = 1*self.alpha
        ret[ret<0] = -1*self.alpha
        return ret
        
        raise NotImplementedError

    def l2_grad(self, weights):
        """
        Compute the *gradient* of L2 regularization
            with respect to the given weights.

        L2 regularization is the squared value, so the partial gradient
            for a given weight should be proportional to that weight

        Note: weights[0, :] contains the intercept, and you should not apply
            regularization to those parameters.
        """
        ret = weights.copy()
        ret[0,:] = 0
        ret = self.alpha*2*ret 
        return ret
        raise NotImplementedError
