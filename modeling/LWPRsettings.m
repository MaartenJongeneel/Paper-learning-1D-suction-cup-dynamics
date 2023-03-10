model = lwpr_set(model, 'norm_in', normalization');
model = lwpr_set(model,'init_D',init_D);
model = lwpr_set(model, 'update_D', 0); % first find optimal init_D with update_D = 0, then set this to 1 and learn using optimal init_D
model = lwpr_set(model,'init_alpha',250);
model = lwpr_set(model,'w_gen',0.2);
model = lwpr_set(model,'diag_only',0);
model = lwpr_set(model,'meta',1);
model = lwpr_set(model,'meta_rate',250);
model = lwpr_set(model,'kernel','Gaussian');
model = lwpr_set(model, 'init_lambda', 0.999);
