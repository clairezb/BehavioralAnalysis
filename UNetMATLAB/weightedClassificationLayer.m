classdef weightedClassificationLayer < nnet.layer.ClassificationLayer
        
    properties
        % (Optional) Layer properties.

        % Layer properties go here.
    end
 
    methods
        function layer = weightedClassificationLayer(name)           
            
            % set the layer name
            layer.Name = name;
            
            % set layer description
            layer.Description = 'weighted';
            
        end

        function loss = forwardLoss(layer, Y, T)
            % loss returns the mean squared difference between prediction Y
            % and target T
            
            % calculate the mean squared difference as loss
            N = size(Y,4);
            loss = sum((Y-T).^2)/N;
           
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % dLdY returns the derivative of loss
            
            N = size(Y,4);
            dLdY = 2*(Y-T)/N;

        end
    end
end

