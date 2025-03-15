#!/usr/bin/env bash

for node_item in comfyui_controlnet_aux comfyui_ipadapter_plus comfyui-cogvideoxwrapper comfyui-custom-scripts comfyui-hunyuanvideowrapper comfyui-impact-pack comfyui-kolors-mz comfyui-mixlab-nodes comfyui-videohelpersuite easyanimate rgthree-comfy was-node-suite-comfyui
    do
        echo "install $node_item"
        comfy node registry-install $node_item
    done
