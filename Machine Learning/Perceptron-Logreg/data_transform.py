import numpy as np


def polynomial_transform(data, degree):
    """
    Perform a polynomial transformation on `data`
        If `data` is an Nx1 matrix with a single column X and degree is 3,
        this will return an Nx3 matrix containing [X, X^2, X^3] columns
        If `data` is an Nx2 matrix with columns X and Y, and degree is 2,
        this will return an Nx4 matrix containing [X, Y, X^2, Y^2] columns

    Note:
        You may find `np.power` and `np.tile` or `np.stack` to be helpful.

    Args:
        data: a NxK matrix of data
        degree: the degree of polynomial with which to transform

    Returns:
        A Nx(K * degree) matrix containing the polynomial transformation
    """
    new_data = np.tile(data, degree)
    power = np.arange(degree+1)[1:]
    power = np.repeat(power, data.shape[1])
    power = np.tile(power, (data.shape[0],1))
    output = np.power(new_data, power)
    return output
    raise NotImplementedError


def custom_transform(data):
    """
    Transform the `spiral.csv` data such that it can be easily classified
        by Perceptron or LogisticRegression.

    Note:
        To pass test_custom_transform_easy, your transformation should
        create no more than 8 features and should allow your logistic regression
        classifier to achieve at least 75% accuracy.

        To pass test_custom_transform_hard, your transformation should
        create only 2 features and should allow your logistic regression
        classifier to achieve 100% accuracy.

    Args:
        data: a Nx2 matrix from the `spiral.csv` dataset.

    Returns:
        A transformed data matrix that is easily classified.
    """

   
   # output = np.zeros((data.shape[0], 2))
   # for i in range(data.shape[0]):
      #  output[i][0] = data[i][0]
      #  output[i][1] = (data[i][0]  + data[i][1])**2
    x,y = data[:,0], data[:,1]
    r = np.sqrt(x**2+y**2)          # coordinate conversion code source: w3resource.com
    theta = np.arctan2(y,x)
    output = np.zeros((data.shape[0], 2))
    for i in range(data.shape[0]):
        output[i][0] = r[i]%2
        output[i][1] = (r[i]+theta[i])%2
    
    return output

    raise NotImplementedError

