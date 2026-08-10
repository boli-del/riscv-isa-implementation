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
            if(prediction_totals_location[input] == 0) return 0.5;

            int index = input % 4096;
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

            //sigmoid
            double sum = logit_loc + logit_usf + logit_conf + logit_hist;
            return 1.0 / (1.0 + exp(-sum));
        }

        void update(uint32_t input, bool correct){
            int index = input % 4096;
            total_predictions++;
            prediction_totals_location[input]++;
            prediction_totals_usefulness[lut[index].first]++;
            prediction_totals_confidence[lut[index].second]++;
            prediction_totals_history[pred_hist & 0xF]++;
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
};