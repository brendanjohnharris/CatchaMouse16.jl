CC = gcc
CFLAGS = -std=c99 -fPIC -Wall -Wextra -g -O2 -lm -lgsl -lgslcblas
LDFLAGS = -shared -lm -lgsl -lgslcblas
RM = rm -f
TARGET_LIB = "lib${SRC_NAME}.${dlext}"

SRCS = main.c fft.c stats.c helper_functions.c histcounts.c CO_AddNoise.c CO_AutoCorr.c CO_HistogramAMI.c CO_NonlinearAutocorr.c CO_TranslateShape.c DN_RemovePoints.c FC_LoopLocalSimple.c IN_AutoMutualInfoStats.c PH_Walker.c SC_FluctAnal.c ST_LocalExtrema.c SY_DriftingMean.c SY_SlidingWindow.c

OBJS = $(SRCS:.c=.o)
.PHONY: all;
all: ${TARGET_LIB}
$(TARGET_LIB): $(OBJS)
	$(CC) ${LDFLAGS} -o $@ $^
$(SRCS:.c=.d):%.d:%.c
	$(CC) $(CFLAGS) -MM $< >$@\ninclude $(SRCS:.c=.d)
.PHONY: clean
clean:-${RM} ${TARGET_LIB} ${OBJS} $(SRCS:.c=.d)
