#include <vector>
#include <iostream>
#include <map>
#include <utility>
#include <cmath>
#include <cstdint>

using namespace std;
// specific input shapes
// need a past history
// need a location
// need usefulness
// need recent misprediction
// need confidence

class regression_classifier{
    public:
        double predict(uint32_t input){
            double threshold = 0.02;
            int index = input % 4096;
            if(variance(index) > threshold) return 0.5;
            int usef = lut[index].first;
            int conf = lut[index].second;

            //extract expected value/probability from here
            double loc = (double)prediction_successes_location[input] / prediction_totals_location[input];
            double usf_p = (double)prediction_successes_usefulness[usef]/prediction_totals_usefulness[usef];
            double conf_p = (double)prediction_successes_confidence[conf]/prediction_totals_confidence[conf];
            double hist_p = (double)prediction_successes_history[pred_hist & 0xF]/prediction_totals_history[pred_hist & 0xF];

            //clac logits
            double logit_loc = logit(loc);
            double logit_usf = logit(usf_p);
            double logit_conf = logit(conf_p);
            double logit_hist = logit(hist_p);

            double w_loc = 1.0 / weight_variance_calc((double)prediction_successes_location[input] + 1,(double)(prediction_totals_location[input]-prediction_successes_location[input] + 1));
            double w_usf = 1.0 / weight_variance_calc((double)(prediction_successes_usefulness[usef] + 1), (double)(prediction_totals_usefulness[usef] - prediction_successes_usefulness[usef] + 1));
            double w_conf = 1.0 / weight_variance_calc((double)(prediction_successes_confidence[conf] + 1), (double)(prediction_totals_confidence[conf] - prediction_successes_confidence[conf] + 1));
            double w_hist = 1.0 / weight_variance_calc((double)(prediction_successes_history[pred_hist & 0xF] + 1), (double)(prediction_totals_history[pred_hist & 0xF] - prediction_successes_history[pred_hist & 0xF] + 1));

            //sigmoid
            double sum = (w_loc * logit_loc) + (w_usf * logit_usf) + (w_conf * logit_conf) + (w_hist * logit_hist);
            return 1.0 / (1.0 + exp(-sum));
        }

        void update(uint32_t input, bool correct){
            int index = input % 4096;
            total_predictions++;
            prediction_totals_location[input]++;
            prediction_totals_usefulness[lut[index].first]++;
            prediction_totals_confidence[lut[index].second]++;
            prediction_totals_history[pred_hist & 0xF]++;

            update_bayesian(correct, index);

            if(correct){
                prediction_successes_location[input]++;
                prediction_successes_usefulness[lut[index].first]++;
                prediction_successes_confidence[lut[index].second]++;
                prediction_successes_history[pred_hist & 0xF]++;
                if(lut[index].first < 3) lut[index].first++;
                if(lut[index].second < 3) lut[index].second++;
            }
            else{
                if(lut[index].first > 0) lut[index].first--;
                if(lut[index].second > 0) lut[index].second--;
            }
            pred_hist = (pred_hist << 1) | correct;
        }
    private:
        int total_predictions = 0;
        map<uint32_t, pair<int, int>> lut;
        map<uint32_t, pair<int, int>> bayesian;
        uint16_t pred_hist = 0;
        map<uint32_t, int> prediction_successes_location;
        map<int, int> prediction_successes_usefulness;
        map<int, int> prediction_successes_confidence;
        map<int, int> prediction_successes_history;
        map<uint32_t, int> prediction_totals_location;
        map<int, int> prediction_totals_usefulness;
        map<int, int> prediction_totals_confidence;
        map<int, int> prediction_totals_history;

        //ln estimation for fixed point floating point number
        // taking the second order taylor series estimation for small enough input:
        double ln_estimation(double input){
            // 2nd order taylor approx for ln(1+x)
            return (input - 1) - (((1 - input)*(1 - input))/2);
        }

        double logit(double p){
            if(p >= 1) p = 0.999;
            double input = p/(1-p);  //for actual implementation just ignore remainder
            return log(input);
        }

        double variance(int index){
            if(bayesian[index].first == bayesian[index].second && bayesian[index].first == 0){
                bayesian[index].first = 1;
                bayesian[index].second = 1;
            }
            double a = bayesian[index].first;
            double b = bayesian[index].second;
            double sum = a + b;
            return (a * b)/((sum * sum) *(sum + 1));
        }
        
        double weight_variance_calc(double a, double b){
            double  sum = a + b;
            return (a * b)/((sum * sum) * (sum + 1));
        }

        //updating the bayesian of the pair depending on hit or miss
        void update_bayesian(bool h_m, int index){
            //true meaning hit, false meaning miss
            if(h_m){
                bayesian[index].first ++;
            }else{
                bayesian[index].second ++;
            }
        }
};