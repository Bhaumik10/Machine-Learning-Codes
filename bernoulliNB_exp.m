%% HW2 Spam detection exercise - ENRON EMAILS
%% Homework Template File, Spring 2015
%% Written by L. Hellerstein and Edison Zhao
%%
%% The version of the Enron dataset used in the data file enron.mat
%% was taken from Homework 1 of CSCI1420, Brown University, 2013
%% cs.brown.edu/courses/csci1420/

clear all; close all; clc;
format long;

% Load the data from the course directory
load('enron.mat');

% VARIABLES IN 'enron.mat'
% trainFeat: sparse matrix of word counts for training documents.
% trainLabels: matrix of {0,1} training labels where 0=ham,1=spam.
% testFeat: sparse matrix of word counts for test documents.
% testLabels: matrix of test document labels.
% vocab: cell array giving word (character string) for each vocabulary index.

% valFeat: sparse matrix of word counts for validation documents. (we don't use)
% valLabels: matrix of validation document labels. (we don't use)

%% "Binarize" the matrices trainFeat and testFeat by replacing all positive entries with the number 1
[x,y,a]=find(trainFeat);
[q,r]=size(trainFeat);
[a1,a2]=size(a);
for f=1:a1
    a(f,1)=1;
end
trainFeat = sparse(x,y,a,q,r);

[x,y,a]=find(testFeat);
[q,r]=size(testFeat);
[a3,a4]=size(a);
for f=1:a3
    a(f,1)=1;
end
testFeat = sparse(x,y,a,q,r);
%% Calculate the total number of spam and ham emails
num_spam = sum(trainLabels == 1);
num_ham = sum(trainLabels ~= 1);

%%Calculate the prior proabilities of ham and spam.  No smoothing.
spam_prior = sum(trainLabels)/(size(trainLabels,1));
ham_prior = sum(trainLabels ~= 1)/(size(trainLabels,1));

%% Calculate total number of spam emails containing each term w, then do the same for ham
spam_w_freq = trainLabels' * trainFeat;
ham_w_freq =  (1-trainLabels') * trainFeat;
%% For each term w, compute the estimate of P(w|spam), 
%% the probability that w occurs, given that the email is spam.
%% Also, for each term w, compute the estimate of P(w|ham).
%% Similarly, compute the estimate of P(not w|spam)
%% and P(not w|ham), the conditional probabilities that w does not occur.
%% Remember to smooth!  Since the feature corresponding
%% to w has 2 possible values, true or false, t=2 in our smoothing formula.

spam_w_prob = ((spam_w_freq + 0.1)/(size(trainLabels,1) + 0.1*2));
ham_w_prob =  ((ham_w_freq + 0.1)/(size(trainLabels,1) + 0.1*2));

spam_notw_prob = 1 - spam_w_prob ;
ham_notw_prob = 1 - ham_w_prob;

%% Calculate the logs of P(w|spam) and P(w|ham)
spam_w_log_prob = log(spam_w_prob);
ham_w_log_prob = log(ham_w_prob);

%% Calculate the logs of P(not w|spam) and P(not w|ham)
spam_notw_log_prob = log(spam_notw_prob);
ham_notw_log_prob =  log(ham_notw_prob);

% Using the values computed above, for all emails Y in the training set,
% we want to calculate log P(spam|Y)*P(spam) and log P(ham|Y)*P(ham).
%
% To do this, we will use that fact that if
% x is a variable that is 1 when w occurs in a given email, and 0 when w
% does not occur, then 
% log P(x|spam) = x*log P(w|spam) + (1-x)*log P(not w|spam).
% Multiplying out the second term, and rearranging, we get
%
% P(x|spam) = x*log P(w|spam) + (log P(not w|spam) - x*log P(not w|spam)) 
%
% By multiplying out this way, we avoid the computation of (1-x).  This is
% important because we will be subsituting trainFeat for x, and we do not
% want to calculate (1-trainFeat), the bitwise complement of the matrix
% trainFeat.  It has too many non-zero entries and calculating it would cause our
% runtime to be slow.  Also note that the second term in the above
% expression is independent of x.

sum_spam_notw_log_prob = sum(spam_notw_log_prob);
sum_ham_notw_log_prob = sum(ham_notw_log_prob);
% For each training email,
% calculate the sum of (log P(not w|spam) - x*log P(not w|spam)) over all words w, where x=1 if w
% occurs, and x=0 otherwise.
%
% In the next line, note that sum_spam_notw_log_prob is a scalar that corresponds to
% log P(not w|spam), which is independent of x.  It is added to all entries
% of the matrix -(spam_notw_log_prob*transpose(trainFeat))

spam_notw_train_term = sum_spam_notw_log_prob - spam_notw_log_prob*transpose(trainFeat);
ham_notw_train_term = sum_ham_notw_log_prob - ham_notw_log_prob*transpose(trainFeat);
% Calculate log P(email|spam) + log(spam), for each training email.
% log(spam_prior) is a scalar that is added to all entries of the computed
% vector
spam_prob_train = (spam_w_log_prob * transpose(trainFeat) + spam_notw_train_term) + log(spam_prior);

% Do the analogous computation for ham_prob_train
ham_prob_train = (ham_w_log_prob * transpose(trainFeat) + ham_notw_train_term) + log(ham_prior);

predict_result_train = (spam_prob_train > ham_prob_train)';

%%What percent accuracy did you obtain on the TRAINING set (accuracy = 1 - error)? 
eer_train = nnz(predict_result_train - trainLabels);

disp('Accuracy on Training Set:')
1 - eer_train/length(trainLabels)

%% Now compute accuracy on the TEST set, using same approach
%% Calculate the total number of spam and ham emails
num_spam_test = sum(testLabels == 1);
num_ham_test = sum(testLabels ~= 1);

%%Calculate the prior proabilities of ham and spam.  No smoothing.
spam_prior_test = sum(testLabels)/(size(testLabels,1));
ham_prior_test = sum(testLabels ~= 1)/(size(testLabels,1));

%% Calculate total number of spam emails containing each term w, then do the same for ham
spam_w_freq_test = testLabels' * testFeat; 
ham_w_freq_test =  (1-testLabels') * testFeat;                                  % mtimesx((trainLabels ~=1),'T',trainFeat);

%% For each term w, compute the estimate of P(w|spam), 
%% the probability that w occurs, given that the email is spam.
%% Also, for each term w, compute the estimate of P(w|ham).
%% Similarly, compute the estimate of P(not w|spam)
%% and P(not w|ham), the conditional probabilities that w does not occur.
%% Remember to smooth!  Since the feature corresponding
%% to w has 2 possible values, true or false, t=2 in our smoothing formula.

spam_w_prob_test = ((spam_w_freq_test + 0.1)/(size(testLabels,1) + 0.1*2));
ham_w_prob_test =  ((ham_w_freq_test + 0.1)/(size(testLabels,1) + 0.1*2));

spam_notw_prob_test = 1 - spam_w_prob_test ;
ham_notw_prob_test = 1 - ham_w_prob_test;

%% Calculate the logs of P(w|spam) and P(w|ham)
spam_w_log_prob_test = log(spam_w_prob_test);
ham_w_log_prob_test = log(ham_w_prob_test);

%% Calculate the logs of P(not w|spam) and P(not w|ham)
spam_notw_log_prob_test = log(spam_notw_prob_test);
ham_notw_log_prob_test =  log(ham_notw_prob_test);

% Using the values computed above, for all emails Y in the training set,
% we want to calculate log P(spam|Y)*P(spam) and log P(ham|Y)*P(ham).
%
% To do this, we will use that fact that if
% x is a variable that is 1 when w occurs in a given email, and 0 when w
% does not occur, then 
% log P(x|spam) = x*log P(w|spam) + (1-x)*log P(not w|spam).
% Multiplying out the second term, and rearranging, we get
%
% P(x|spam) = x*log P(w|spam) + (log P(not w|spam) - x*log P(not w|spam)) 
%
% By multiplying out this way, we avoid the computation of (1-x).  This is
% important because we will be subsituting trainFeat for x, and we do not
% want to calculate (1-trainFeat), the bitwise complement of the matrix
% trainFeat.  It has too many non-zero entries and calculating it would cause our
% runtime to be slow.  Also note that the second term in the above
% expression is independent of x.

%sum_spam_notw_log_prob_test = sum(spam_notw_log_prob_test);
%sum_ham_notw_log_prob_test = sum(ham_notw_log_prob_test);
% For each training email,
% calculate the sum of (log P(not w|spam) - x*log P(not w|spam)) over all words w, where x=1 if w
% occurs, and x=0 otherwise.
%
% In the next line, note that sum_spam_notw_log_prob is a scalar that corresponds to
% log P(not w|spam), which is independent of x.  It is added to all entries
% of the matrix -(spam_notw_log_prob*transpose(trainFeat))

spam_notw_train_term_test = sum_spam_notw_log_prob - spam_notw_log_prob*transpose(testFeat);
ham_notw_train_term_test = sum_ham_notw_log_prob - ham_notw_log_prob*transpose(testFeat);
% Calculate log P(email|spam) + log(spam), for each training email.
% log(spam_prior) is a scalar that is added to all entries of the computed
% vector
spam_prob_test = (spam_w_log_prob * transpose(testFeat) + spam_notw_train_term_test) + log(spam_prior);

% Do the analogous computation for ham_prob_train
ham_prob_test = (ham_w_log_prob * transpose(testFeat) + ham_notw_train_term_test) + log(ham_prior);


predict_result_test = (spam_prob_test > ham_prob_test)';

eer_test = nnz(predict_result_test - testLabels);
%%What percent accuracy did you obtain on the TEST set
disp('Accuracy on Test Set:')
1 - eer_test/length(testLabels)
