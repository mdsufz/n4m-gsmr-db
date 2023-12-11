import sys
import cobra
from cobra.io import read_sbml_model
from reframed import load_cbmodel, save_cbmodel, Environment, set_default_solver
from cobra.medium import minimal_medium

model = read_sbml_model("/work/magnusdo/evoniche/reconstructions/reconstructions_prodigal/" + sys.argv[1])

# maximum growth
max_growth = model.slim_optimize()

# identify minimal media
minmed = minimal_medium(model, minimize_components=True)

# save minimal media
minmed.to_csv(path_or_buf="/work/magnusdo/evoniche/minmedia/" + sys.argv[1] + ".csv", sep = ",", header = False)

# allow unlimited minimal media
minmed = minmed.replace(to_replace = minmed.values, value = 1000)
model.medium = minmed

# optimal growth on unlimited minimal media
mmGrowth = model.slim_optimize()

# save results
my_list = [sys.argv[1], max_growth, mmGrowth, len(minmed)]
my_string = ','.join(map(str, my_list))
my_string = my_string + "\n"

with open('/work/magnusdo/evoniche/model.growth.minmedia.csv', 'a') as the_file:
    the_file.write(my_string)

