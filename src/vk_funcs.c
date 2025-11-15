#include "vk_funcs.h"
#include "logging.h"
#include <string.h>

XenoVulkanFuncs g_vk_funcs = {0};

void xeno_load_vulkan_funcs(PFN_vkGetDeviceProcAddr getProcAddr, VkDevice device) {
    if (!getProcAddr || !device) {
        XENO_LOGE("vk_funcs: Invalid parameters to xeno_load_vulkan_funcs");
        return;
    }
    
    #define LOAD_VK_FUNC(name) \
        g_vk_funcs.name = (PFN_##name)getProcAddr(device, #name); \
        if (!g_vk_funcs.name) XENO_LOGW("vk_funcs: Failed to load " #name);
    
    // Shader and pipeline functions
    LOAD_VK_FUNC(vkCreateShaderModule);
    LOAD_VK_FUNC(vkDestroyShaderModule);
    LOAD_VK_FUNC(vkCreateDescriptorSetLayout);
    LOAD_VK_FUNC(vkDestroyDescriptorSetLayout);
    LOAD_VK_FUNC(vkCreatePipelineLayout);
    LOAD_VK_FUNC(vkDestroyPipelineLayout);
    LOAD_VK_FUNC(vkCreatePipelineCache);
    LOAD_VK_FUNC(vkDestroyPipelineCache);
    LOAD_VK_FUNC(vkCreateComputePipelines);
    LOAD_VK_FUNC(vkDestroyPipeline);
    LOAD_VK_FUNC(vkCreateDescriptorPool);
    LOAD_VK_FUNC(vkDestroyDescriptorPool);
    LOAD_VK_FUNC(vkAllocateDescriptorSets);
    LOAD_VK_FUNC(vkUpdateDescriptorSets);
    
    // Image and memory functions
    LOAD_VK_FUNC(vkCreateImageView);
    LOAD_VK_FUNC(vkDestroyImageView);
    LOAD_VK_FUNC(vkCreateImage);
    LOAD_VK_FUNC(vkDestroyImage);
    LOAD_VK_FUNC(vkGetImageMemoryRequirements);
    LOAD_VK_FUNC(vkAllocateMemory);
    LOAD_VK_FUNC(vkFreeMemory);
    LOAD_VK_FUNC(vkBindImageMemory);
    
    // Buffer functions
    LOAD_VK_FUNC(vkCreateBuffer);
    LOAD_VK_FUNC(vkDestroyBuffer);
    
    // Sampler functions
    LOAD_VK_FUNC(vkCreateSampler);
    LOAD_VK_FUNC(vkDestroySampler);
    
    // Render pass and framebuffer functions
    LOAD_VK_FUNC(vkCreateRenderPass);
    LOAD_VK_FUNC(vkDestroyRenderPass);
    LOAD_VK_FUNC(vkCreateFramebuffer);
    LOAD_VK_FUNC(vkDestroyFramebuffer);
    
    // Command buffer functions
    LOAD_VK_FUNC(vkCmdBindPipeline);
    LOAD_VK_FUNC(vkCmdBindDescriptorSets);
    LOAD_VK_FUNC(vkCmdPushConstants);
    LOAD_VK_FUNC(vkCmdDispatch);
    LOAD_VK_FUNC(vkCmdPipelineBarrier);
    
    #undef LOAD_VK_FUNC
    
    XENO_LOGI("vk_funcs: Loaded all Vulkan device functions");
}
