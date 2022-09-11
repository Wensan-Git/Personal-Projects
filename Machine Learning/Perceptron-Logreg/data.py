import numpy as np
import pandas as pd


def load_data(data_path):
    """
    This function loads the data in data_path csv into two numpy arrays:
    features (of size NxK) and targets (of size Nx1) where N is the number of rows
    and K is the number of features.

    Args:
        data_path (str): path to csv file containing the data

    Output:
        features (np.array): numpy array of size NxK containing the K features
        targets (np.array): numpy array of size 1xN containing the N targets.
        attribute_names (list): list of strings containing names of each attribute
            (headers of csv)
    """
    if data_path.endswith('gz'):
        df = pd.read_csv(data_path, compression='gzip')
    else:
        df = pd.read_csv(data_path)

    feature_columns = [col for col in df.columns if col != "class"]
    features = df[feature_columns].to_numpy()
    target = df["class"].to_numpy()

    return features, target, feature_columns


def cross_validation(features, targets, folds):
    """
    Split the data in `folds` different groups for cross-validation.
        Split the features and targets into a `folds` number of groups that
        divide the data as evenly as possible. Then for each group,
        return a tuple that treats that group as the test set and all
        other groups combine to make the training set.

        Note that this should be *deterministic*; don't shuffle the data.
        If there are 100 examples and you have 5 folds, each group
        should contain 20 examples and the first group should contain
        the first 20 examples.

        See test_cross_validation for expected behavior.

    Args:
        features: an NxK matrix of N examples, each with K features
        targets: an Nx1 array of N labels
        folds: the number of cross-validation groups

    Output:
        A list of tuples, where each tuple contains:
          (train_features, train_targets, test_features, test_targets)
    """

    assert features.shape[0] == targets.shape[0]

    if folds == 1:
        return [(features, targets, features, targets)]
    
    output = []
    set_total = int(features.shape[0]/folds)
    for i in range(folds):
        if i != folds -1:
            train_features = np.copy(features)
            train_targets = np.copy(targets)
            test_features = np.copy(features)
            test_targets = np.copy(targets)
            train_features = np.delete(train_features, slice(i*set_total, i*set_total + set_total), 0)
            train_targets = np.delete(train_targets, slice(i*set_total, i*set_total + set_total), 0)
            test_features = test_features[i*set_total:i*set_total + set_total, :]
            test_targets = test_targets[i*set_total:i*set_total + set_total]
        else:
            train_features = np.copy(features)
            train_targets = np.copy(targets)
            test_features = np.copy(features)
            test_targets = np.copy(targets)
            train_features = np.delete(train_features, slice(i*set_total, features.shape[0]), 0)
            train_targets = np.delete(train_targets, slice(i*set_total, features.shape[0]), 0)
            test_features = test_features[i*set_total:, :]
            test_targets = test_targets[i*set_total:]
        output.append((train_features, train_targets, test_features, test_targets))
        
    return output
    raise NotImplementedError
