// Weak Vulkan stubs for functions that might not be in GameHub's libvulkan
// These will be overridden by the real implementations if they exist

#include <vulkan/vulkan.h>

#define WEAK_STUB(name) \
    __attribute__((weak)) VkResult name() { return VK_ERROR_FEATURE_NOT_PRESENT; }

WEAK_STUB(vkCreatePipelineCache)
WEAK_STUB(vkDestroyPipelineCache)
WEAK_STUB(vkCreateComputePipelines)
WEAK_STUB(vkDestroyPipeline)
WEAK_STUB(vkCreateShaderModule)
WEAK_STUB(vkDestroyShaderModule)
WEAK_STUB(vkCreateDescriptorSetLayout)
WEAK_STUB(vkDestroyDescriptorSetLayout)
WEAK_STUB(vkCreatePipelineLayout)
WEAK_STUB(vkDestroyPipelineLayout)
WEAK_STUB(vkCreateDescriptorPool)
WEAK_STUB(vkDestroyDescriptorPool)
WEAK_STUB(vkAllocateDescriptorSets)
WEAK_STUB(vkUpdateDescriptorSets)
WEAK_STUB(vkCreateImageView)
WEAK_STUB(vkDestroyImageView)
WEAK_STUB(vkCmdBindPipeline)
WEAK_STUB(vkCmdBindDescriptorSets)
WEAK_STUB(vkCmdPushConstants)
WEAK_STUB(vkCmdDispatch)
WEAK_STUB(vkCmdPipelineBarrier)
