#%%
import threading
import sys
sys.path.append("AnalysisModules")
import DQMInputHandler
import MessageHandlerFFT
import MessageHandlerMeanRMS
import MessageHandlerRawEventsTransform


#%%

def StartDQMModuleHandling(name):
    print("Started DQM module handling", name)
    DQMInputHandler.consumerInitlizer()
    print("Thread %s: finishing", name)

def StartMessageHandlerFFT(name):
    print("Started Fast Fourrier transform", name)
    MessageHandlerFFT.consumerInitlizer()
    print("Thread %s: finishing", name)

def StartMessageHandlerMRMS(name):
    print("Started Mean and Root Mean Square", name)
    MessageHandlerMeanRMS.consumerInitlizer()
    print("Thread %s: finishing", name)

def StartMessageHandlerRET(name):
    print("Started Raw event transform", name)
    MessageHandlerRawEventsTransform.consumerInitlizer()
    print("Thread %s: finishing", name)


#%%
if __name__ == "__main__":

    handling = threading.Thread(target=StartDQMModuleHandling, args=("DQM-HANDLING",))
    fft = threading.Thread(target=StartMessageHandlerFFT, args=("DQM-FFT",))
    mrms = threading.Thread(target=StartMessageHandlerMRMS, args=("DQM-MRMS",))
    ret = threading.Thread(target=StartMessageHandlerRET, args=("DQM-RET",))


    handling.start()
    fft.start()
    mrms.start()
    ret.start()

# %%
