import numpy as np


def compute_confusion_matrix(actual, predictions):
    """
    Given predictions (an N-length numpy vector) and actual labels (an N-length
    numpy vector), compute the confusion matrix. The confusion
    matrix for a binary classifier would be a 2x2 matrix as follows:

    [
        [true_negatives, false_positives],
        [false_negatives, true_positives]
    ]

    You do not need to implement confusion matrices for labels with more
    classes. You can assume this will always be a 2x2 matrix.

    Compute and return the confusion matrix.

    Args:
        actual (np.array): predicted labels of length N
        predictions (np.array): predicted labels of length N

    Output:
        confusion_matrix (np.array): 2x2 confusion matrix between predicted and actual labels

    """

    if predictions.shape[0] != actual.shape[0]:
        raise ValueError("predictions and actual must be the same length!")
        
    output = np.zeros((2,2))
    t_p = np.sum(np.logical_and(predictions == True, actual == True))
    t_n = np.sum(np.logical_and(predictions == False, actual == False))
    f_p = np.sum(np.logical_and(predictions == True, actual == False))
    f_n = np.sum(np.logical_and(predictions == False, actual == True))
    output[0][0] = t_n
    output[0][1] = f_p
    output[1][0] = f_n
    output[1][1] = t_p
    return output

    raise NotImplementedError


def compute_accuracy(actual, predictions):
    """
    Given predictions (an N-length numpy vector) and actual labels (an N-length
    numpy vector), compute the accuracy:

    Hint: implement and use the compute_confusion_matrix function!

    Args:
        actual (np.array): predicted labels of length N
        predictions (np.array): predicted labels of length N

    Output:
        accuracy (float): accuracy
    """
    if predictions.shape[0] != actual.shape[0]:
        raise ValueError("predictions and actual must be the same length!")
    
    matrix = compute_confusion_matrix(actual, predictions)
    correct_number = matrix[0][0] + matrix[1][1]
    return float(correct_number/(actual.shape[0]))

    raise NotImplementedError


def compute_precision_and_recall(actual, predictions):
    """
    Given predictions (an N-length numpy vector) and actual labels (an N-length
    numpy vector), compute the precision and recall:

    https://en.wikipedia.org/wiki/Precision_and_recall

    You MUST account for edge cases in which precision or recall are undefined
    by returning np.nan in place of the corresponding value.

    Hint: implement and use the compute_confusion_matrix function!

    Args:
        actual (np.array): predicted labels of length N
        predictions (np.array): predicted labels of length N

    Output a tuple containing:
        precision (float): precision
        recall (float): recall
    """
    if predictions.shape[0] != actual.shape[0]:
        raise ValueError("predictions and actual must be the same length!")
    
    matrix = compute_confusion_matrix(actual, predictions)
    t_n = matrix[0][0]
    f_p = matrix[0][1]
    f_n = matrix[1][0]
    t_p = matrix[1][1]
    if f_p+ t_p != 0:
        precision = t_p/(f_p+t_p)
    else:
        precision = np.nan
    if f_n+t_p != 0:
        recall = t_p/(f_n+t_p)
    else:
        recall = np.nan
    return (precision, recall)
    
    raise NotImplementedError


def compute_f1_measure(actual, predictions):
    """
    Given predictions (an N-length numpy vector) and actual labels (an N-length
    numpy vector), compute the F1-measure:

    https://en.wikipedia.org/wiki/Precision_and_recall#F-measure

    Because the F1-measure is computed from the precision and recall scores, you
    MUST handle undefined (NaN) precision or recall by returning np.nan. You
    should also consider the case in which precision and recall are both zero.

    Hint: implement and use the compute_precision_and_recall function!

    Args:
        actual (np.array): predicted labels of length N
        predictions (np.array): predicted labels of length N

    Output:
        f1_measure (float): F1 measure of dataset (harmonic mean of precision and
        recall)
    """
    if predictions.shape[0] != actual.shape[0]:
        raise ValueError("predictions and actual must be the same length!")
    precision, recall = compute_precision_and_recall(actual, predictions)
    if np.isnan(precision) or np.isnan(recall) or (precision == 0 and recall == 0):
        return np.nan
    return float(2*(precision*recall/(precision+recall)))
    
    raise NotImplementedError
