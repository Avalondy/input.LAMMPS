# flat surface deposition, using Stillinger-Weber(SW) potential for Si-Si

units		metal
atom_style      charge
boundary        f f f

variable xl equal 0
variable xh equal 10
variable yl equal 0
variable yh equal 10
variable zl equal 0
variable zh equal 10

lattice		diamond 5.4307
region          box block ${xl} ${xh} ${yl} ${yh} ${zl} ${zh}
create_box      2 box

variable sub_xl equal (${xh}-${xl})*0.1+${xl}
variable sub_xh equal (${xh}-${xl})*0.9+${xl}
variable sub_yl equal (${yh}-${yl})*0.1+${yl}
variable sub_yh equal (${yh}-${yl})*0.9+${yl}
variable sub_zl equal ${zl}
variable sub_zh equal (${zh}-${zl})*0.4+${zl}
region		substrate block ${sub_xl} ${sub_xh} ${sub_yl} ${sub_yh} ${sub_zl} ${sub_zh}

create_atoms	1 region substrate

mass		1 28.0
mass		2 39.95

set atom 2 charge 50

pair_style hybrid sw zbl 8.0 10.0 coul/cut 10.0
pair_coeff * * sw Si.sw Si NULL
pair_coeff 1 2 zbl 14.0 18.0
pair_coeff 2 2 coul/cut


neigh_modify	delay 0


variable mob_zl equal (${zh}-${zl})*0.1+${zl}
variable mob_zh equal ${zh}
group		addatoms type 2
region      mobile block ${xl} ${xh} ${yl} ${yh} ${mob_zl} ${mob_zh}
group		mobile region mobile

compute		add addatoms temp
compute_modify	add dynamic/dof yes extra/dof 0

fix		1 addatoms nve
fix		2 mobile langevin 1.0 1.0 0.1 587283
fix		3 mobile nve

variable slab_xl equal (${xh}-${xl})*0.2+${xl}
variable slab_xh equal (${xh}-${xl})*0.8+${xl}
variable slab_yl equal (${yh}-${yl})*0.1+${yl}
variable slab_yh equal (${yh}-${yl})*0.4+${yl}
variable slab_zl equal (${zh}-${zl})*0.45+${zl}
variable slab_zh equal (${zh}-${zl})*0.45+${zl}
# region          slab block ${slab_xl} ${slab_xh} ${slab_yl} ${slab_yh} ${slab_zl} ${slab_zh}
region          slab block ${slab_xl} ${slab_xh} ${slab_yl} ${slab_yh} ${slab_zl} ${slab_zh}
# sqrt(2*100eV*1.602E-19/6.633E-26) = 220 Angstrom/ps
# 220*cos(85)=19.174, 220*sin(85)=219.163
fix		4 addatoms deposit 100 2 200 12345 region slab near 1.0 &
                vz -19.174 -19.174 vy 219.163 219.163 units box
                # vz -10.0 -10.0 vy 30.0 30.0 units box

# fix		5 addatoms wall/reflect xlo EDGE xhi EDGE ylo EDGE yhi EDGE zlo EDGE zhi EDGE
fix		5 addatoms wall/reflect zlo EDGE

thermo_style	custom step atoms temp epair etotal press
thermo          100
thermo_modify	temp add
thermo_modify   lost warn

dump		1 addatoms custom 50 dump.deposit.atom.velocity.txt id type xs ys zs vx vy vz

# dump		2 all image 100 image.*.jpg type type &
# 		axes yes 0.8 0.02 view 70 -10 size 1920 1080
# dump_modify	2 pad 5

dump		3 all movie 25 movie.Si.zbl.sw.mpg type type &
		axes yes 0.8 0.02 view 90 0  size 1920 1080  # 80 -5
dump_modify	3 pad 5

timestep 0.0001
run             10000
