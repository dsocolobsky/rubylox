import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def plot_data():
    # Read the CSV file into a DataFrame
    df = pd.read_csv('meditions.csv')
    #df = df[df['n'] >= 25]


    # Group the data by 'lang' and 'n', and calculate the mean and standard deviation
    grouped_data = df.groupby(['lang', 'n'])['time'].agg(['mean', 'std'])

    # Separate data for each language
    rubylox_data = grouped_data.loc['rubylox']
    jlox_data = grouped_data.loc['jlox']

    # Plot data for each language with different colors
    plt.errorbar(rubylox_data.index, rubylox_data['mean'], yerr=rubylox_data['std'], label='RubyLox', marker='o', linestyle='-', color='r')
    plt.errorbar(jlox_data.index, jlox_data['mean'], yerr=jlox_data['std'], label='JLox', marker='s', linestyle='--', color='b')

    # Add labels and title
    plt.xlabel('n')
    plt.ylabel('Tiempo (segundos)')
    plt.title('Fibonacci(n) Tiempo de Ejecucion')
    plt.legend()

    # Set the number of Y-axis ticks
    num_ticks = 25
    yticks = plt.MaxNLocator(num_ticks)
    plt.gca().yaxis.set_major_locator(yticks)

    # Show the plot
    plt.show()


def plot_benchmark_bars():
    # Read the CSV file into a DataFrame
    df = pd.read_csv('meditions_multiple.csv')
    # filter df so that benchmark is not trees nor binary_trees
    df = df[df['benchmark'] != 'trees']
    df = df[df['benchmark'] != 'binary_trees']

    # Set the figure size
    plt.figure(figsize=(12, 6))

    # Get unique benchmarks from the DataFrame
    benchmarks = df['benchmark'].unique()

    # Define bar width and positions for grouped bars
    bar_width = 0.25
    positions = np.arange(len(benchmarks))

    pastel_red = (1.0, 0.6, 0.6)
    pastel_blue = (0.6, 0.6, 1.0)

    # Loop through each language and plot grouped bars for each benchmark
    languages = df['lang'].unique()
    for i, language in enumerate(languages):
        df_language = df[df['lang'] == language]
        time_values = df_language['time'].values

        color = pastel_red if language == 'rubylox' else pastel_blue
        plt.bar(positions + i * bar_width, time_values, bar_width, label=language, color=color)

    # Add labels and title
    plt.xlabel('Benchmark')
    plt.ylabel('Time (s)')
    plt.title('Benchmark Times')
    plt.xticks(positions + bar_width / 2, benchmarks)
    plt.legend()

    # Show the plot
    plt.show()

if __name__ == "__main__":
    #plot_data()
    plot_benchmark_bars()
