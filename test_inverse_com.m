% test inverse
id_var = rand(2,2);
id_var = id_var*id_var';

video_var = rand(2,2);
video_var = video_var*video_var';

noise_var = rand(2,2);
noise_var = noise_var*noise_var';

a = id_var + video_var + noise_var;
b = id_var + video_var;
c = id_var;

tmp = [a, b, b; b, a, b; b, b, a];
% tmp1 = inv(tmp);
% tmp2 = get_struct_inv(id_var, video_var, noise_var, 3);

tmp3 = [a, b; b, a];
tmp4 = [c, c; c, c; c,c];
tmp = [tmp, tmp4; tmp4', tmp3];
tmp1 = inv(tmp);
tmp2 = get_struct_inv(id_var, video_var, noise_var,[3,2]);
ccc = 0;