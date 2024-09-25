#include <iostream>
using namespace std;

int main(void){
    //000000011001
    //101110100111
    //110010111111
    //101111101010
    //110100100001
    //101100110011
    //010010011101
    //111111011011
    int arr[8][12] = {
        {0,0,0,0,0,0,0,1,1,0,0,1},
        // {1,0,0,1,1,1,0,0,1,1,0,1},
        {1,0,1,1,1,0,1,0,0,1,1,1},
        {1,1,0,0,1,0,1,1,1,1,1,1},
        {1,0,1,1,1,1,1,0,1,0,1,0},
        {1,1,0,1,0,0,1,0,0,0,0,1},
        {1,0,1,1,0,0,1,1,0,0,1,1},
        {0,1,0,0,1,0,0,1,1,1,0,1},
        {1,1,1,1,1,1,0,1,1,0,1,1}
    };
    for(int i = 0;i<8;i++){
        int h1,h2,h4,h8;
        int ans[12];
        h1 = arr[i][0]^arr[i][2]^arr[i][4]^arr[i][6]^arr[i][8]^arr[i][10];
        h2 = arr[i][1]^arr[i][2]^arr[i][5]^arr[i][6]^arr[i][9]^arr[i][10];
        h4 = arr[i][3]^arr[i][4]^arr[i][5]^arr[i][6]^arr[i][11];
        h8 = arr[i][7]^arr[i][8]^arr[i][9]^arr[i][10]^arr[i][11];
        cout << "E:" << arr[i][0] << arr[i][1] << arr[i][2] << arr[i][3] << arr[i][4] << arr[i][5] << arr[i][6] << arr[i][7] << arr[i][8] << arr[i][9] << arr[i][10] << arr[i][11] << endl;
        int H = h8*8 + h4*4 + h2*2 + h1;
        cout << "H:" << h8 << h4 << h2 << h1 << " means: "<< H << endl;
        int err;
        int cor;
        int out;
        if(H > 12){
            cout << "multiple errors" << endl;
            err = 1;
            cor = 0;
            out = 0;
            for(int j = 0;j<12;j++) ans[j] = 0;
        }
        else if(H <= 12 && H >=1){
            cout <<"one error" << endl;
            err = 0;
            cor = 0;
            out = H;
            for(int j = 0;j<12;j++) ans[j] = arr[i][j];
            ans[H-1] = !arr[i][H-1];
        }
        else{
            cout << "no error" << endl;
            for(int j = 0;j<12;j++) ans[j] = arr[i][j];
            err = 0;
            cor = 1;
            out = 0;
        }
        cout << "O:" << arr[i][2] << arr[i][4] << arr[i][5] << arr[i][6] << arr[i][8] << arr[i][9] << arr[i][10] << arr[i][11] << endl;
        cout << "A:" << ans[2] << ans[4] << ans[5] << ans[6] << ans[8] << ans[9] << ans[10] << ans[11] << endl;
        cout << "out:" << out << endl;
        cout << "Error: " << err << " Correction: " << cor << endl << "\n";
    }
}