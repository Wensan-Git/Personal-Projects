try:
    import matplotlib
    import matplotlib.pyplot as plt
except:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

#import data
#import numpy as np

#import numpy as np
#import pandas as pd


#def load_data(data_path):
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
 #   if data_path.endswith('gz'):
    #    df = pd.read_csv(data_path, compression='gzip')
  #  else:
   #     df = pd.read_csv(data_path)

    #feature_columns = [col for col in df.columns if col != "class"]
    #features = df[feature_columns].to_numpy()
    #target = df["class"].to_numpy()

#    return features, target, feature_columns

#features, target, features_columns = load_data("/Users/yinjiacheng/Desktop/College/课程内容/大二第三学期/hw2-perceptron-logreg-Wensan-Git/data/parallel-lines.csv")

#rows1 = np.where(target[:] == 1)
#rows0 = np.where(target[:] == 0)
#features1 = features[rows1]
#features0 = features[rows0]
#plt.scatter(features1[:,0], features1[:,1], color = "blue")
#plt.scatter(features0[:,0], features0[:,1], color = "red")






